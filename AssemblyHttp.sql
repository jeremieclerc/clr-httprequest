-- Active clr if disabled
IF (SELECT TOP 1 value FROM sys.configurations WHERE name = 'clr enabled') != 1
BEGIN
    EXEC sp_configure 'clr enabled', 1
    RECONFIGURE
END
DECLARE @sql nvarchar(MAX), @hash varbinary(64)
-- the following binary correspond to the assembly
DECLARE @clrBinary varbinary(MAX) = 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C0103006D38E4660000000000000000E00022200B013000002600000006000000000000DA44000000200000006000000000001000200000000200000400000000000000060000000000000000A000000002000000000000030060850000100000100000000010000010000000000000100000000000000000000000884400004F00000000600000B802000000000000000000000000000000000000008000000C000000504300001C0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E74657874000000E0240000002000000026000000020000000000000000000000000000200000602E72737263000000B8020000006000000004000000280000000000000000000000000000400000402E72656C6F6300000C0000000080000000020000002C00000000000000000000000000004000004200000000000000000000000000000000BC440000000000004800000002000500C02B00009017000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001B3006002C09000001000011000F00FE16090000016F0600000A6F0700000A6F0800000A0A0F01FE16090000016F0600000A0B0F02FE16090000016F0600000A0C0F03FE16090000016F0600000A0D1613041613051613067201000070130772010000701308730900000A1309730A00000A130A00067203000070280B00000A2C4E06720B000070280B00000A2C41067215000070280B00000A2C3406721D000070280B00000A2C27067227000070280B00000A2C1A067235000070280B00000A2C0D067241000070280B00000A2B0116130B110B2C1900725100007006729D000070280C00000A130700382A060000077236010070280D00000A130C110C2C0E007240010070130700380B060000076F0E00000A19310F076F0E00000A20D0070000FE022B0117130D110D2C28007282010070076F0E00000A130E120E280F00000A721B02007007281000000A13070038C40500000020C00F0000281100000A0007281200000A740C000001130F110F066F1300000A0000087236010070280B00000A2C0B086F0E00000A16FE022B011613121112399B0400000008280300000613130011136F1400000A131438650400001214281500000A1315001215281600000A6F0700000A131A111A131911192805000006131B111B20B2E12165357D111B20E9179E20352D111B2058D565023B370100002B00111B208915C00E3B130100002B00111B20E9179E203BC300000038CC030000111B2019C0262A351F111B204E5CE2253B590100002B00111B2019C0262A3BB100000038A4030000111B20681F23613B920100002B00111B20B2E121653B420100003885030000111B200C056CB1352D111B20A46517833B800100002B00111B207D28CF9C3B460100002B00111B200C056CB13BE0000000384F030000111B2099F407C0351C111B204669E5B93BB00000002B00111B2099F407C02E4D382A030000111B20757E29EB3BEC0000002B00111B202F3EF0ED2E73380E03000011197237020070280D00000A3A2301000038F802000011197245020070280D00000A3A2101000038E20200001119725B020070280D00000A3A3701000038CC02000011197265020070280D00000A3A3A01000038B602000011197289020070280D00000A3A3D01000038A002000011197297020070280D00000A3A3B010000388A020000111972A1020070280D00000A3A390100003874020000111972B1020070280D00000A3A37010000385E020000111972D5020070280D00000A3A350100003848020000111972EB020070280D00000A3A330100003832020000111972F7020070280D00000A3A64010000381C02000011197211030070280D00000A3A6201000038060200001119722F030070280D00000A3A7101000038F00100001119723F030070280D00000A3A8801000038DA010000110F1215281700000A6F1800000A0038FA0100001215281700000A6F0700000A724D030070280D00000A131C111C2C0B00110F166F1900000A000038CE010000110F1215281700000A281A00000A6F1B00000A0038B5010000110F1215281700000A281A00000A6F1C00000A00389C010000110F1215281700000A6F1D00000A003888010000110F1215281700000A6F1E00000A003874010000110F1215281700000A6F1F00000A003860010000110F1215281700000A6F2000000A00384C010000110F1215281700000A6F2100000A0038380100001215281700000A178D2600000125161F2D9D6F2200000A131611168E6918FE01131D111D2C1C00110F1116169A282300000A1116179A282300000A6F2400000A000038F1000000110F1215281700000A6F2500000A0038DD0000001215281700000A1217282600000A131E111E2C0C00110F11176F2700000A000038B80000001215281700000A1218282800000A131F111F2C1400110F1118163003152B0211186F2900000A0000388B0000001215281700000A6F0700000A7259030070280D00000A132011202C3900110F256F2A00000A7E05000004252D17267E04000004FE0609000006732B00000A258005000004282C00000A741C0000016F2D00000A00002B341215281600000A6F0E00000A18FE02132111212C1D00110F6F2E00000A1215281600000A1215281700000A6F2F00000A00002B00001214283000000A3A8FFBFFFFDE0F1214FE160200001B6F3100000A00DC00067203000070280B00000A2C16096F0E00000A16310D097236010070280B00000A2B0116132211222C6300283200000A096F3300000A1323110416FE01132511252C0F00110F72650300706F2500000A0000110516FE01132611262C0F00110F11238E696A6F2700000A0000110F6F3400000A1324112411231611238E696F3500000A0011246F3600000A0000110F6F3700000A740D000001131011106F3800000A733900000A131111116F3A00000A130711106F3B00000A130611106F3C00000A130911106F3D00000A0011116F3E00000A0000DE0C260072A9030070130700DE000000DE6E13270011276F3F00000A14FE03132811282C440011276F3F00000A750D000001132911296F3B00000A130611276F3F00000A6F3800000A733900000A6F3A00000A130711296F3C00000A130911296F3D00000A00002B140011276F4000000A130711276F4100000A13060000DE0011096F4200000A16FE02132A112A39D800000000720904007013080011096F4300000A132B16132C3895000000112B112C9A132D001C8D2000000125161108A22517720D040070A22518112DA225197211040070A2251A1109112D6F4400000A7219040070721D0400706F4500000A720D04007072230400706F4500000A7229040070722D0400706F4500000A723304007072370400706F4500000A723D04007072410400706F4500000AA2251B7247040070A2284600000A130800112C1758132C112C112B8E693F60FFFFFF110811086F0E00000A1759176F4700000A724D040070284800000A13080011072C0C11076F0E00000A16FE012B0117132E112E2C050014130700110620091513803307110714FE032B0116132F112F2C4800110772510400706F4900000A133011302C120011077259040070284800000A1307002B22110772EA0400706F4900000A133111312C1000110772FA040070284800000A1307000011082C0C11086F0E00000A16FE012B0117133211322C050014130800110A1106284A00000A1107284B00000A1108284B00000A73060000066F4C00000A26110A13332B0011332A414C000002000000A2010000780400001A0600000F00000000000000000000006C01000095050000010700000C000000140000010000000068000000A9060000110700006E00000013000001133002002D00000002000011000274040000020A03067B01000004811500000104067B02000004810900000105067B0300000481090000012A0000001B3005001E0100000300001100734D00000A0A026F0800000A10000272090400706F4E00000A2C0D02724D0400706F4F00000A2B01160D092C1E0002176F5000000A10000216026F0E00000A17596F5100000A1000002B0C00727A050070735200000A7A72D4050070735300000A0B07026F5400000A0C00086F5500000A13042B7C11046F5600000A741900000113050011056F5700000A176F5800000A6F5900000A130611056F5700000A186F5800000A6F5900000A13071107720D0400706F4E00000A2C0E1107720D0400706F4F00000A2B0116130811082C16001107178D2600000125161F229D6F5A00000A13070006110611076F5B00000A000011046F5C00000A3A78FFFFFFDE161104751A000001130911092C0811096F3100000A00DC06130A2B00110A2A000001100000020074008C000116000000002202285D00000A002A000000133002002E00000004000011022C2920C59D1C810A160B2B1402076F5E00000A066120930100015A0A0717580B07026F0E00000A2F022BE1062A7A02285D00000A000002037D0100000402047D0200000402057D030000042A2E730800000680040000042A0A172A42534A4201000100000000000C00000076342E302E33303331390000000005006C0000008C050000237E0000F8050000D807000023537472696E677300000000D00D00001806000023555300E8130000100000002347554944000000F81300009803000023426C6F620000000000000002000001571502080902000000FA0133001600000100000032000000050000000500000009000000110000005E0000000600000004000000030000000100000003000000020000000000E803010000000000060098028B050600B8028B0506006F0278050F00AB0500000600CE0647040A00830236050A00E900360506005E0136060A000A03C2050E009704E00606005A0736060E003807E0060E00E601E0060600EF047E0006003600A1003F006005000006002700A10006002E047E000E00AB04E0060600B80447040A001E00C2050E008E0717060E00770417060600510536060E002703170606006A014704060054028B050E007403C10706002202D7050E005304D7050E009006C1070600160347040600210047040E000E05E0060E008701E0060E003C07E0060600760147040600EA0447040600430047040600450247040E006304C0000600010382070E00EA01E0060600FC047E000E002E01E0060600BE0447040E00C001C0000E00870417060E00E40417060E00B801170600000000560000000000010001000100100049060000150001000100000100005F00000015000100050003001000C3060000150001000600032110009D00000015000400070006003D01F20106009407F60106007F06F60136005200FA0116000100FE0150200000000096004E0702020100D42900000000960047070F020500102A000000009100C8041D0209004C2B0000000086186B0506000A00582B0000000093002D0327020A00922B0000000086186B052C020B00B12B000000009118710536020E004C2B0000000086186B0506000E00BD2B0000000083000A003A020E0000000100AC01000002000E04000003008806000004009A07000001007003020002003E0102000300F90102000400800600000100D20400000100BA06000001003E01000002009507000003008006000001000705000002003202000003005D0400000400A00609006B05010011006B05060019006B050A0031006B050600D9006B05060029001403620001012205620001014E04620051006B05060059006B0506000101B30766000101BC066C000101A707660001013F0373000901140362000101BC0677001101F9037F0021013E0286002101F8008D000C005D05990014001707AB001C009F07BD001C00D602C20061002D078D006100E002C70029011302CC0061001902D30061000B01D3006100D5068D00610064078D0061002A058D006100F5028D00610009078D000101F706DA0009011302E10061005501E60021019C018D0039011002EC0021014A03F30009011002F80021016D07010061009803FF00E1006B05040141017F010A016100C0031601210173061C014901BC002101140079072701D10008020600510149002B0151010506310121012404370191004E023C019100020206002101F601440159011204370171006B054A016101DF00620069001F015001590173061C015901020206006101020206009900D90144017101490162007101FD0673007901230773004901B0065601490135045B010101030160010101BC0666010101EE026C010101BC06720101010E067801A900EB067D014900EB0683015900BC0089010C006B05060001016503780101015C03780101011D03B00101011D036C01A1006B058D00B1006B058D00B100BA05B501B9005D05BB01C1001707C001C9005E06C40181013504CA019101D602620001014E04D1010C003E04D701C1007907270129006B05060001016906E4012000230076022E000B0045022E0013004E022E001B006D0263002B009103A3002B00910310008E019301DF019200A400B600048000000000000000000000000000000000D7040000040000000000000000000000E901940000000000040000000000000000000000E901880000000000040000000000000000000000E90147040000000004000200050002000000003C3E395F5F315F30003C48747470526571756573743E625F5F315F300053716C496E743332004B657956616C75655061697260320044696374696F6E617279603200496E743634006765745F55544638003C3E39003C4D6F64756C653E003C50726976617465496D706C656D656E746174696F6E44657461696C733E0053797374656D2E494F0053797374656D2E44617461006D73636F726C6962003C3E630053797374656D2E436F6C6C656374696F6E732E47656E65726963004164640053797374656D2E436F6C6C656374696F6E732E5370656369616C697A65640052656164546F456E6400446174614163636573734B696E64007365745F4D6574686F64005265706C616365007365745F49664D6F64696669656453696E6365006765745F537461747573436F64650048747470537461747573436F64650072537461747573436F6465006765745F4D6573736167650041646452616E67650049456E756D657261626C650049446973706F7361626C65004461746554696D6500436F6D62696E6500536563757269747950726F746F636F6C54797065007365745F436F6E74656E74547970650072657175657374547970650043617074757265004E616D654F626A656374436F6C6C656374696F6E42617365006765745F526573706F6E73650048747470576562526573706F6E736500476574526573706F6E736500436C6F736500446973706F7365005472795061727365007365745F4461746500583530394365727469666963617465006365727469666963617465004372656174650044656C656761746500577269746500436F6D70696C657247656E6572617465644174747269627574650044656275676761626C654174747269627574650053716C46756E6374696F6E41747472696275746500436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C697479417474726962757465006765745F56616C7565007365745F4B656570416C6976650052656D6F7665007365745F5472616E73666572456E636F64696E670053716C537472696E6700546F537472696E6700537562737472696E67004D6174636800436F6D70757465537472696E6748617368006765745F4C656E677468007365745F436F6E74656E744C656E67746800456E6473576974680053746172747357697468006F626A0052656D6F7465436572746966696361746556616C69646174696F6E43616C6C6261636B006765745F536572766572436572746966696361746556616C69646174696F6E43616C6C6261636B007365745F536572766572436572746966696361746556616C69646174696F6E43616C6C6261636B00417373656D626C79487474702E646C6C007365745F536563757269747950726F746F636F6C0075726C00476574526573706F6E736553747265616D004765745265717565737453747265616D006765745F4974656D007365745F4974656D0053797374656D005472696D0058353039436861696E00636861696E004E616D6556616C7565436F6C6C656374696F6E004D61746368436F6C6C656374696F6E0047726F7570436F6C6C656374696F6E00576562486561646572436F6C6C656374696F6E00576562457863657074696F6E00466F726D6174457863657074696F6E0050617273654A736F6E006A736F6E00417373656D626C79487474700047726F757000436861720053747265616D52656164657200546578745265616465720073656E6465720053657276696365506F696E744D616E6167657200546F5570706572007365745F52656665726572004D6963726F736F66742E53716C5365727665722E5365727665720049456E756D657261746F7200476574456E756D657261746F72002E63746F72002E6363746F720053797374656D2E446961676E6F73746963730053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300446562756767696E674D6F646573004D6174636865730053797374656D2E446174612E53716C54797065730053797374656D2E53656375726974792E43727970746F6772617068792E5835303943657274696669636174657300476574427974657300436F6E7461696E730053797374656D2E546578742E526567756C617245787072657373696F6E730053797374656D2E436F6C6C656374696F6E730055736572446566696E656446756E6374696F6E73006765745F47726F757073006765745F4368617273006765745F4865616465727300724865616465727300686561646572730053736C506F6C6963794572726F72730073736C506F6C6963794572726F7273006765745F416C6C4B65797300436F6E63617400487474705265706F6E73654F626A656374007365745F4578706563740053797374656D2E4E6574006F705F496D706C696369740053706C6974006765745F48526573756C74007365745F557365724167656E74006765745F43757272656E74006765745F436F756E74007365745F4163636570740048747470576562526571756573740046696C6C526F7748747470526571756573740041727261794C697374007365745F486F7374007365745F54696D656F7574004D6F76654E6578740053797374656D2E546578740052656765780072426F647900626F6479006765745F4B6579006F705F457175616C697479006F705F496E657175616C6974790053797374656D2E4E65742E53656375726974790000000000010007470045005400000950004F0053005400000750005500540000094800450041004400000D440045004C00450054004500000B54005200410043004500000F4F005000540049004F004E005300004B4D006500740068006F00640020006E006F007400200073007500700070006F0072007400650064002E0020004D006500740068006F00640073002000750073006500640020003A0020000080972E0020004C0069007300740020006F006600200073007500700070006F00720074006500640020006D006500740068006F006400730020003A0020004700450054002C00200050004F00530054002C0020005000550054002C00200048004500410044002C002000440045004C004500540045002C002000540052004100430045002C0020004F005000540049004F004E0053002E0000094E0075006C006C00004150006C00650061007300650020007300700065006300690066007900200061006E002000550052004C00200074006F0020007200650071007500650073007400008097550052004C0020006E006F007400200073007500700070006F0072007400650064002E002000550052004C0020006C0065006E0067007400680020006D0075007300740020006200650020006200650074007700650065006E0020003300200061006E006400200032003000300030002E002000430075007200720065006E00740020006C0065006E0067007400680020003A002000001B2E002000550052004C002000560061006C00750065003A002000000D410043004300450050005400001543004F004E004E0045004300540049004F004E00000944004100540045000023490046002D004D004F004400490046004900450044002D00530049004E0043004500010D450058005000450043005400000948004F0053005400000F520045004600450052004500520000235400520041004E0053004600450052002D0045004E0043004F00440049004E004700011555005300450052002D004100470045004E005400010B520041004E0047004500001943004F004E00540045004E0054002D005400590050004500011D43004F004E00540045004E0054002D004C0045004E00470054004800010F540049004D0045004F0055005400000D560045005200490046005900000B43004C004F0053004500000B460041004C005300450000436100700070006C00690063006100740069006F006E002F0078002D007700770077002D0066006F0072006D002D00750072006C0065006E0063006F00640065006400015F4A0053004F004E002000740065007800740020006900730020006E006F0074002000700072006F007000650072006C007900200066006F0072006D00610074007400650064002E002000280040006800650061006400650072007300290000037B0000032200000722003A00220000035C0000055C005C0000055C00220000030A0000055C006E0000030D0000055C0072000003090000055C007400000522002C0000037D000007530053004C0000808F200059006F0075002000630061006E00200062007900700061007300730020007400680065002000530053004C002F0054004C005300200063006800650063006B0020007500730069006E0067002000740068006500200020006800650061006400650072003A0020007B00220056006500720069006600790022003A002200460061006C007300650022007D00000F740069006D0065006F0075007400007F200059006F0075002000630061006E00200069006E00630072006500610073006500200079006F00750072002000740069006D0065006F007500740020007500730069006E006700200074006800650020006800650061006400650072003A0020007B002200540069006D0065006F007500740022003A002D0031007D0001594A0053004F004E002000730068006F0075006C00640020007300740061007200740020007700690074006800200027007B002700200061006E006400200065006E00640020007700690074006800200027007D0027002E000141220028005B005E0022005D002B00290022005C0073002A003A005C0073002A00280022005B005E0022005D002A0022007C005B0030002D0039005D002B002900010000A5D1DDFFC01CC3419358B5DC8C726255000420010108032000010520010111115107340E0E0E0E0202080E0E1229122D020202081231123512390215123D020E0E151141020E0E151145020E0E1D0E0A080E0E09020202020202021D0512490202124D021235021D0E080E020202020212210320000E050002020E0E0600030E0E0E0E032000080700040E0E0E0E0E0600010111808D0600011280910E042001010E0615123D020E0E0A2000151141021300130106151141020E0E0A2000151145021300130106151145020E0E0420001300042000130104200101020600011180950E062001011180950620011D0E1D03040001080E052002010808060002020E100A042001010A060002020E10080420001271052002011C180B00021280A11280A11280A10520010112710420001229052002010E0E032000020500001280A90520011D050E0420001249072003011D0508080520001280AD0520010112490520001180B50420001D0E0420010E0E0520020E0E0E0500010E1D0E0520020E08080500020E0E0E042001020E05000111550805000111250E042001081C04070112101C070B15123D020E0E1259125D02126112650E0E02126915123D020E0E0420010E08052001125D0E04200012610320001C0520001280C10620011280C5080520010E1D0307200201130013010407020908042001030808B77A5C561934E089030611550306112503061214030612710C0004122111251125112511250D0004011C10115510112510112509000115123D020E0E0E040001090E09200301115511251125030000010A2004021C12751279117D0801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F777301080100070100000000811901000400540E1146696C6C526F774D6574686F644E616D651246696C6C526F774874747052657175657374540E0F5461626C65446566696E6974696F6E3D537461747573436F646520494E542C20526573706F6E7365204E56415243484152284D4158292C2048656164657273204E56415243484152284D4158295455794D6963726F736F66742E53716C5365727665722E5365727665722E446174614163636573734B696E642C2053797374656D2E446174612C2056657273696F6E3D342E302E302E302C2043756C747572653D6E65757472616C2C205075626C69634B6579546F6B656E3D623737613563353631393334653038390A446174614163636573730100000054020F497344657465726D696E69737469630004010000000000000000006D38E46600000000020000001C0100006C4300006C250000525344536511292F35D7BA44905393810F0D4ED601000000433A5C55736572735C6D65796E69656C615C736F757263655C7265706F735C48747470526571756573745C417373656D626C79487474705C6F626A5C44656275675C417373656D626C79487474702E70646200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000B04400000000000000000000CA440000002000000000000000000000000000000000000000000000BC440000000000000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF2500200010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001001000000018000080000000000000000000000000000001000100000030000080000000000000000000000000000001000000000048000000586000005C02000000000000000000005C0234000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100000000000000000000000000000000003F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B004BC010000010053007400720069006E006700460069006C00650049006E0066006F0000009801000001003000300030003000300034006200300000002C0002000100460069006C0065004400650073006300720069007000740069006F006E000000000020000000300008000100460069006C006500560065007200730069006F006E000000000030002E0030002E0030002E003000000042001100010049006E007400650072006E0061006C004E0061006D006500000041007300730065006D0062006C00790048007400740070002E0064006C006C00000000002800020001004C006500670061006C0043006F0070007900720069006700680074000000200000004A00110001004F0072006900670069006E0061006C00460069006C0065006E0061006D006500000041007300730065006D0062006C00790048007400740070002E0064006C006C0000000000340008000100500072006F006400750063007400560065007200730069006F006E00000030002E0030002E0030002E003000000038000800010041007300730065006D0062006C0079002000560065007200730069006F006E00000030002E0030002E0030002E00300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000C000000DC3400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000    

-- trust the assembly with sp_add_trusted_assembly
SET @hash = (SELECT TOP 1 hash FROM sys.trusted_assemblies WHERE description = 'AssemblyHttp')
IF @hash IS NOT NULL EXEC sp_drop_trusted_assembly @hash
DROP FUNCTION IF EXISTS dbo.HttpRequest
DROP ASSEMBLY IF EXISTS AssemblyHttp

SET @hash = HASHBYTES('SHA2_512', @clrBinary)
EXEC sp_add_trusted_assembly @hash, N'AssemblyHttp'

-- Create the assembly and the function associated
CREATE ASSEMBLY AssemblyHttp AUTHORIZATION [dbo] FROM @clrBinary WITH PERMISSION_SET = UNSAFE;

EXEC ('CREATE FUNCTION dbo.HttpRequest(@requestType AS NVARCHAR(8), @url AS NVARCHAR(MAX), @headers AS NVARCHAR(MAX), @body AS NVARCHAR(MAX)) 
    RETURNS TABLE (StatusCode INT, Response NVARCHAR(MAX), Headers NVARCHAR(MAX)) AS EXTERNAL NAME [AssemblyHttp].UserDefinedFunctions.HttpRequest')
