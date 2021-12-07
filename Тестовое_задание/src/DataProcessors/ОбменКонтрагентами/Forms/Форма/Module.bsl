
&НаКлиенте
Процедура СформироватьXML(Команда)

	СформироватьXMLСервер();	
	
КонецПроцедуры

&НаСервере
Процедура СформироватьXMLСервер()

	ПространствоИменABM = Метаданные.ПакетыXDTO.Контрагенты.ПространствоИмен; 	
	КонтрагентыXDTO = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(ПространствоИменABM, "Контрагенты"));    
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	Контрагенты.Ссылка,
	|	Контрагенты.Код КАК Код,
	|	Контрагенты.Наименование КАК Наименование,  	
	|	ВЫБОР 
	|		КОГДА Контрагенты.Класс = ЗНАЧЕНИЕ(Перечисление.КлассыКонтрагентов.ЮрЛицо) ТОГДА ""ЮрЛицо""
	|		КОГДА Контрагенты.Класс = ЗНАЧЕНИЕ(Перечисление.КлассыКонтрагентов.ФизЛицо) ТОГДА ""ФизЛицо""
	|		ИНАЧЕ ""Неопределено""
	|	КОНЕЦ КАК Класс
	|
	|ИЗ
	|	Справочник.Контрагенты КАК Контрагенты
	|";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		КонтрагентXDTO = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(ПространствоИменABM, "Контрагент"));
		КонтрагентXDTO.Идентификатор = XMLСтрока(Выборка.Ссылка);
		КонтрагентXDTO.Код = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(ПространствоИменABM, "Код"), XMLСтрока(Выборка.Код));
		КонтрагентXDTO.Наименование = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(ПространствоИменABM, "Наименование"), XMLСтрока(Выборка.Наименование));
		КонтрагентXDTO.Класс = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(ПространствоИменABM, "Классы"), XMLСтрока(Выборка.Класс));
		
		КонтрагентыXDTO.Контрагент.Добавить(КонтрагентXDTO);
		
	КонецЦикла;	
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку("UTF-8");
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	
	ФабрикаXDTO.ЗаписатьXML(ЗаписьXML, КонтрагентыXDTO); 
	
	СтрокаXML = ЗаписьXML.Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьXML(Команда)
	
	ЗагрузитьXMLСервер();
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьXMLСервер()
	
	Если ПустаяСтрока(СтрокаXML) Тогда 
		Сообщить("Ничего не загружено");
		Возврат;
	КонецЕсли;
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(СтрокаXML);
	ОбъектXDTO = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML);  	
	ЧтениеXML.Закрыть();
	
	Если ОбъектXDTO <> Неопределено И ЕстьПолеВОбъектеXDTO(ОбъектXDTO, "Контрагент") Тогда
		
		СписокЭлементов = ПолучитьМассивОбъектовXDTO(ОбъектXDTO.Контрагент);
		
		Для Каждого ЭлементXDTO Из СписокЭлементов Цикл 
			
			СпрСсылка = Справочники.Контрагенты.ПолучитьСсылку(Новый УникальныйИдентификатор(ЭлементXDTO.Идентификатор));
			
			СпрОбъект = СпрСсылка.ПолучитьОбъект(); 
			Если СпрОбъект = Неопределено Тогда 
				СпрОбъект = Справочники.Контрагенты.СоздатьЭлемент();
				СпрОбъект.УстановитьСсылкуНового(СпрСсылка);
			КонецЕсли;
			
			СпрОбъект.Код = ЭлементXDTO.Код;
			СпрОбъект.Наименование = ЭлементXDTO.Наименование;
			СпрОбъект.Класс = ПолучитьКласс(ЭлементXDTO.Класс);
			СпрОбъект.Записать();
			
			ТекстСообщения = """Загружен"" элемент:
			|GUID: " + ЭлементXDTO.Идентификатор + " 
			|Код: " + ЭлементXDTO.Код + "
			|Наименование: " + ЭлементXDTO.Наименование + " 
			|Класс: " + ЭлементXDTO.Класс; 
			
			Сообщить(ТекстСообщения);			
			
		КонецЦикла;		
		
	КонецЕсли; 	
	
КонецПроцедуры

&НаСервере
Функция ПолучитьКласс(ИмяКласса)
	
	Для Каждого Кл Из Метаданные.Перечисления.КлассыКонтрагентов.ЗначенияПеречисления Цикл
		
		Если ИмяКласса = Кл.Имя Тогда 
			Возврат Перечисления.КлассыКонтрагентов[Кл.Имя];
		КонецЕсли;			
		
	КонецЦикла;
	
	Возврат Перечисления.КлассыКонтрагентов.ПустаяСсылка();	
	
КонецФункции

&НаСервере
Функция ЕстьПолеВОбъектеXDTO(ОбъектXDTO, ИмяПоля)
	
	ЕстьПоле = Ложь;
	
	Если ОбъектXDTO.Свойства().Получить(ИмяПоля) <> Неопределено Тогда
		ЕстьПоле = Истина;
	КонецЕсли;
	
	Возврат ЕстьПоле
	
КонецФункции

Функция ПолучитьМассивОбъектовXDTO(ОбъектXDTO)
	
	Если ТипЗнч(ОбъектXDTO) = Тип("СписокXDTO") Тогда
		СписокЭлементов = ОбъектXDTO;
	Иначе 
		СписокЭлементов = Новый Массив;
		СписокЭлементов.Добавить(ОбъектXDTO);
	КонецЕсли;
	
	Возврат СписокЭлементов;
	
КонецФункции
