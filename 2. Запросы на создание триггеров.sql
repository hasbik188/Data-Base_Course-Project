DELIMITER //
CREATE TRIGGER mts.AutoInsertCalls
AFTER INSERT ON mts.`Клиент`
FOR EACH ROW
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE random_date DATE;

    -- Генерируем случайную дату звонка, позже даты регистрации клиента
    SET random_date = TIMESTAMPADD(DAY, FLOOR(RAND() * DATEDIFF(NOW(), NEW.`Дата_регистрации`)), NEW.`Дата_регистрации`);

    -- Случайное количество звонков от 1 до 5
    SET i = FLOOR(RAND() * 5) + 1;

    WHILE i > 0 DO
        -- Вставляем случайные данные о звонках для нового клиента
        INSERT INTO mts.`Звонок` (`Дата_звонка`, `Время_звонка`, `Длительность_звонка`, `Номер_телефона`, `Код_тарифа`, `Код_города`)
        SELECT random_date, SEC_TO_TIME(FLOOR(RAND() * 86400)), FLOOR(RAND() * 60) + 1, NEW.`Номер_телефона`, `Код_тарифа`, NEW.`Код_города`
        FROM mts.`Тариф`
        WHERE `Код_города` = NEW.`Код_города`
        ORDER BY RAND()
        LIMIT 1;
        SET i = i - 1;
    END WHILE;
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER mts.AutoGenerateInvoice
AFTER INSERT ON mts.`Звонок`
FOR EACH ROW
BEGIN
    DECLARE sum_to_pay DECIMAL(12,2);
    DECLARE end_time DATETIME;

    -- Рассчитываем время завершения звонка
    SET end_time = TIMESTAMP(NEW.`Дата_звонка`, NEW.`Время_звонка`) + INTERVAL NEW.`Длительность_звонка` MINUTE;

    -- Рассчитываем сумму к оплате для данного звонка
    SELECT 
        CASE
            WHEN TIME(NEW.`Время_звонка`) >= '20:00' OR TIME(NEW.`Время_звонка`) < '06:00' THEN NEW.`Длительность_звонка` * t.`Льготная_стоимость_мин`
            ELSE NEW.`Длительность_звонка` * t.`Стоимость_мин`
        END INTO sum_to_pay
    FROM mts.`Тариф` t
    WHERE t.`Код_тарифа` = NEW.`Код_тарифа`;

    -- Вставляем данные в таблицу Квитанция
    INSERT INTO mts.`Квитанция` (`Дата_выставления`, `Дата_оплаты`, `Сумма_к_оплате`, `Код_звонка`)
    VALUES (end_time, end_time, sum_to_pay, NEW.`Код_звонка`);
END //
DELIMITER ;
