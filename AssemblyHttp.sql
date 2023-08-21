-- Active clr if disabled
IF (SELECT TOP 1 value FROM sys.configurations WHERE name = 'clr enabled') != 1
BEGIN
    EXEC sp_configure 'clr enabled', 1
    RECONFIGURE
END
DECLARE @sql nvarchar(MAX), @hash varbinary(64)
-- the following binary correspond to the assembly
DECLARE @clrBinary varbinary(MAX) = 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C0103005D46E3640000000000000000E00022200B013000001E00000006000000000000FA3D0000002000000040000000000010002000000002000004000000000000000600000000000000008000000002000000000000030060850000100000100000000010000010000000000000100000000000000000000000A83D00004F00000000400000B802000000000000000000000000000000000000006000000C000000703C00001C0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E74657874000000001E000000200000001E000000020000000000000000000000000000200000602E72737263000000B8020000004000000004000000200000000000000000000000000000400000402E72656C6F6300000C0000000060000000020000002400000000000000000000000000004000004200000000000000000000000000000000DC3D0000000000004800000002000500482900002813000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001B3006006008000001000011000F00FE16090000016F0600000A6F0700000A0A0F01FE16090000016F0600000A0B0F02FE16090000016F0600000A0C0F03FE16090000016F0600000A0D1613041613051613077201000070130872010000701309730800000A130A730900000A130B168D17000001130C00067203000070280A00000A2C4E06720B000070280A00000A2C41067215000070280A00000A2C3406721D000070280A00000A2C27067227000070280A00000A2C1A067235000070280A00000A2C0D067241000070280A00000A2B0116130D110D2C1400725100007006280B00000A1308003860050000076F0C00000A19311A076F0C00000A20D0070000300D07729D000070280D00000A2B0117130E110E2C280072A7000070076F0C00000A130F120F280E00000A72E900007007280F00000A130800380E0500000020C00F0000281000000A0007281100000A740C00000113101110066F1200000A00086F1300000A0C086F0C00000A16310D08166F1400000A1F7BFE012B0116131311132C42000816176F1500000A0C08086F0C00000A17596F1600000A0C0872050100707215010070281700000A0C08178D1700000125167235010070A2166F1800000A130C0000110C131416131538B2030000111411159A13160011166F1300000A16111672530100706F1900000A6F1A00000A6F1300000A131711176F0C00000A18FE02131911192C1A0011171711176F0C00000A18596F1A00000A6F1300000A13170011166F1300000A111672530100706F1900000A17586F1B00000A6F1300000A131811186F0C00000A17310E1118166F1400000A1F22FE012B0116131A111A2C290011181711186F0C00000A18596F1A00000A6F1300000A7257010070725D0100706F1C00000A131800111772610100701B281D00000A131B111B2C1100111011186F1E00000A000038CC0200001117726F0100701B281D00000A2C0F111872850100701B281D00000A2B0116131C111C2C10001110166F1F00000A00003897020000111772910100701B281D00000A131D111D2C160011101118282000000A6F2100000A0000386E0200001117729B0100701B281D00000A131E111E2C160011101118282000000A6F2200000A00003845020000111772BF0100701B281D00000A131F111F2C1100111011186F2300000A00003821020000111772CD0100701B281D00000A132011202C1100111011186F2400000A000038FD010000111772D70100701B281D00000A132111212C1100111011186F2500000A000038D9010000111772E70100701B281D00000A132211222C1100111011186F2600000A000038B50100001117720B0200701B281D00000A132311232C1100111011186F2700000A00003891010000111772210200701B281D00000A132411242C440011101118161118722D0200706F1900000A17586F1A00000A282800000A11181118722D0200706F1900000A17586F1B00000A282800000A6F2900000A0000383A010000111772310200701B281D00000A132511252C1400111011186F2A00000A001713040038130100001117724B0200701B281D00000A2C0B11181206282B00000A2B0116132611262C190011101118282C00000A6F2D00000A001713050038D9000000111772690200701B281D00000A2C0B11181206282B00000A2B0116132711272C35001118282800000A152E0C1118282800000A16FE022B0117132811282C110011101118282800000A6F2E00000A0000003883000000111772790200701B281D00000A2C0F111872870200701B281D00000A2B0116132911292C3B001110256F2F00000A7E05000004252D17267E04000004FE0607000006733000000A258005000004283100000A74130000016F3200000A00002B2311176F0C00000A18FE02132A112A2C130011106F3300000A111711186F3400000A000000111517581315111511148E693F43FCFFFF067203000070280A00000A132B112B2C6300283500000A096F3600000A132C110416FE01132E112E2C0F00111072930200706F2A00000A0000110516FE01132F112F2C0F001110112C8E696A6F2D00000A000011106F3700000A132D112D112C16112C8E696F3800000A00112D6F3900000A000011106F3A00000A740D000001131111116F3B00000A733C00000A131211126F3D00000A130811116F3E00000A130711116F3F00000A130A11116F4000000A0011126F4100000A000000DE6E13300011306F4200000A14FE03133111312C440011306F4200000A750D000001133211326F3E00000A130711306F4200000A6F3B00000A733C00000A6F3D00000A130811326F3F00000A130A11326F4000000A00002B140011306F4300000A130811306F4400000A13070000DE00110A6F4500000A16FE021333113339D80000000072D7020070130900110A6F4600000A13341613353895000000113411359A1336001C8D1700000125161109A22517725D010070A225181136A2251972DB020070A2251A110A11366F4700000A72E302007072E70200706F1C00000A725D01007072570100706F1C00000A72ED02007072F10200706F1C00000A72F702007072FB0200706F1C00000A720103007072050300706F1C00000AA2251B720B030070A2284800000A130900113517581335113511348E693F60FFFFFF110911096F0C00000A1759176F1500000A7211030070280B00000A13090011082C0C11086F0C00000A16FE012B0117133711372C050014130800110720091513803307110814FE032B0116133811382C4800110872150300706F4900000A133911392C12001108721D030070280B00000A1308002B22110872AE0300706F4900000A133A113A2C1000110872BE030070280B00000A1308000011092C0C11096F0C00000A16FE012B0117133B113B2C050014130900110B1107284A00000A1108284B00000A1109284B00000A73040000066F4C00000A26110B133C2B00113C2A411C0000000000006B000000DA050000450600006E00000010000001133002002D00000002000011000274030000020A03067B01000004811100000104067B02000004810900000105067B0300000481090000012A2202284D00000A002A7A02284D00000A000002037D0100000402047D0200000402057D030000042A2E730600000680040000042A0A172A42534A4201000100000000000C00000076342E302E33303331390000000005006C000000A0040000237E00000C050000C406000023537472696E677300000000D00B0000400400002355530010100000100000002347554944000000201000000803000023426C6F620000000000000002000001571502000902000000FA01330016000001000000280000000400000005000000070000000F0000004D000000050000000200000001000000030000000200000000004803010000000000060026028F04060046028F040600FD017C040F00AF0400000600D9059E030A00110254040A00930054040600080139050A009602BE040E00CE03EB050600590639050E003706EB050E007C01EB0506000D04430006008E0343000E00E203EB050A001E00BE040600E2018F040E00D402AF060600B001D3040E00AA03D3040E009B05AF060600A2029E03060021009E030E002C04EB050E002501EB050E003B06EB050E0084061A05060061059E030600EF039E03060014019E03060027009E030600D3019E030E00BA036A0006008D0278060E008001EB0506001A0443000E00D800EB050600E5039E030E0056016A00000000003A000000000001000100010010004C05000015000100010003001000CE05000015000100040003211000620000001500040005000600E700710106008A06750106008A057501360036007901160001007D0150200000000096004D0681010100D82800000000960046068E01050011290000000086186F04060009001A290000000086186F049C01090039290000000091187504A6010C0011290000000086186F0406000C0045290000000083000A00AA010C00000001004A01000002006E0300000300930500000400900600000100D00202000200E800020003008F01020004008B0500000100E800000002008B06000003008B0500000100250400000200C00100000300B40300000400AB0509006F04010011006F04060019006F040A0031006F04060091006F0406002900A0025D00B90040045D0051006F04060059006F040600B900A1066100B900C7056700B900B3026D00B90095066100C100A0025D00B900C7057100C90059037900D900CC017F00D900A2008500B900A5035D00B90074058A00B90072028F00B90072029500E100AD009A00B9000206A100B9007902AA00B900A9028F00B900A9029500B900AD00AF00B9000A05B50061002C06850061006402BD00F900A101C2006100A701C8006100B500C8006100E0058500610063068500610048048500610081028500610014068500C100A101CE006100FF00D300D9003A01850001019E01D9000101A101E000D900BE02E500D9006C0601006100F802EA0099006F04EF0009011D01F500610020030101D9007E050701110166000C0119012D001201190101051801D90084031E017900DC012301790098010600D9008C012B01210172031E0171006F043101290189005D006900C900370121017E05070121019801060029019801060081006F012B013901F3005D00390108066D00410122066D001101BB053D01110195034201B900C7054701B90011054D018900F60552014900F6055801590066005E0129006F04060020002300E6012E000B00B5012E001300BE012E001B00DD0183002B0001031000630104800000000000000000000000000000000000040000040000000000000000000000680159000000000004000000000000000000000068014D000000000004000000000000000000000068019E030000000003000200040002000000003C3E395F5F315F30003C48747470526571756573743E625F5F315F300053716C496E74333200496E743634006765745F55544638003C3E39003C4D6F64756C653E0053797374656D2E494F0053797374656D2E44617461006D73636F726C6962003C3E63004164640053797374656D2E436F6C6C656374696F6E732E5370656369616C697A65640052656164546F456E6400446174614163636573734B696E64007365745F4D6574686F64005265706C616365007365745F49664D6F64696669656453696E6365006765745F537461747573436F64650048747470537461747573436F64650072537461747573436F6465006765745F4D6573736167650041646452616E67650049456E756D657261626C65004461746554696D6500436F6D62696E6500536563757269747950726F746F636F6C54797065007365745F436F6E74656E7454797065007265717565737454797065004E616D654F626A656374436F6C6C656374696F6E42617365006765745F526573706F6E73650048747470576562526573706F6E736500476574526573706F6E736500436C6F7365005472795061727365007365745F4461746500583530394365727469666963617465006365727469666963617465004372656174650044656C656761746500577269746500436F6D70696C657247656E6572617465644174747269627574650044656275676761626C654174747269627574650053716C46756E6374696F6E41747472696275746500436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C697479417474726962757465007365745F4B656570416C6976650052656D6F766500496E6465784F66007365745F5472616E73666572456E636F64696E670053716C537472696E6700546F537472696E6700537562737472696E67006765745F4C656E677468007365745F436F6E74656E744C656E677468006F626A0052656D6F7465436572746966696361746556616C69646174696F6E43616C6C6261636B006765745F536572766572436572746966696361746556616C69646174696F6E43616C6C6261636B007365745F536572766572436572746966696361746556616C69646174696F6E43616C6C6261636B00417373656D626C79487474702E646C6C007365745F536563757269747950726F746F636F6C0075726C00476574526573706F6E736553747265616D004765745265717565737453747265616D006765745F4974656D0053797374656D005472696D0058353039436861696E00636861696E004E616D6556616C7565436F6C6C656374696F6E00576562486561646572436F6C6C656374696F6E00576562457863657074696F6E00537472696E67436F6D70617269736F6E00417373656D626C79487474700053747265616D52656164657200546578745265616465720073656E6465720053657276696365506F696E744D616E6167657200546F5570706572007365745F52656665726572004D6963726F736F66742E53716C5365727665722E536572766572002E63746F72002E6363746F720053797374656D2E446961676E6F73746963730053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300446562756767696E674D6F6465730053797374656D2E446174612E53716C54797065730053797374656D2E53656375726974792E43727970746F6772617068792E5835303943657274696669636174657300476574427974657300457175616C7300436F6E7461696E730053797374656D2E546578742E526567756C617245787072657373696F6E730053797374656D2E436F6C6C656374696F6E730055736572446566696E656446756E6374696F6E7300537472696E6753706C69744F7074696F6E73006765745F4368617273006765745F4865616465727300724865616465727300686561646572730053736C506F6C6963794572726F72730073736C506F6C6963794572726F7273006765745F416C6C4B65797300436F6E63617400487474705265706F6E73654F626A656374007365745F4578706563740053797374656D2E4E6574006F705F496D706C696369740053706C6974006765745F48526573756C74007365745F557365724167656E74006765745F436F756E74007365745F4163636570740048747470576562526571756573740046696C6C526F7748747470526571756573740041727261794C697374007365745F486F7374007365745F54696D656F75740053797374656D2E546578740052656765780072426F647900626F6479006F705F457175616C697479006F705F496E657175616C6974790053797374656D2E4E65742E5365637572697479000000010007470045005400000950004F0053005400000750005500540000094800450041004400000D440045004C00450054004500000B54005200410043004500000F4F005000540049004F004E005300004B4D006500740068006F00640020006E006F007400200073007500700070006F0072007400650064002E0020004D006500740068006F00640073002000750073006500640020003A00200000094E0075006C006C000041550052004C0020006E006F007400200073007500700070006F0072007400650064002E002000550052004C0020004C0065006E0067007400680020003A002000001B2E002000550052004C002000560061006C00750065003A002000000F5B0030002D00390022005D002C00011F240030003C0053007400720069006E006700530070006C00690074003E00001D2C003C0053007400720069006E006700530070006C00690074003E0000033A0000055C00220000032200000D410063006300650070007400001543006F006E006E0065006300740069006F006E00000B43006C006F0073006500000944006100740065000023490066002D004D006F006400690066006900650064002D00530069006E0063006500010D450078007000650063007400000948006F0073007400000F520065006600650072006500720000235400720061006E0073006600650072002D0045006E0063006F00640069006E006700011555007300650072002D004100670065006E007400010B520061006E006700650000032D00011943006F006E00740065006E0074002D005400790070006500011D43006F006E00740065006E0074002D004C0065006E00670074006800010F540069006D0065006F0075007400000D560065007200690066007900000B660061006C007300650000436100700070006C00690063006100740069006F006E002F0078002D007700770077002D0066006F0072006D002D00750072006C0065006E0063006F0064006500640001037B00000722003A00220000035C0000055C005C0000030A0000055C006E0000030D0000055C0072000003090000055C007400000522002C0000037D000007530053004C0000808F200059006F0075002000630061006E00200062007900700061007300730020007400680065002000530053004C002F0054004C005300200063006800650063006B0020007500730069006E0067002000740068006500200020006800650061006400650072003A0020007B00220056006500720069006600790022003A002200460061006C007300650022007D00000F740069006D0065006F0075007400007F200059006F0075002000630061006E00200069006E00630072006500610073006500200079006F00750072002000740069006D0065006F007500740020007500730069006E006700200074006800650020006800650061006400650072003A0020007B002200540069006D0065006F007500740022003A002D0031007D000100001212E094A7DB2F4CB5E8F3C4EC07B850000420010108032000010520010111114C073D0E0E0E0E02020A080E0E1229122D1D0E020208123112351239021D0E080E0E0E020202020202020202020202020202020202021D05123D02021241021235021D0E080E020202020212210320000E050002020E0E0500020E0E0E032000080700040E0E0E0E0E050001011169050001126D0E042001010E04200103080520020E08080420010E080600030E0E0E0E0820021D0E1D0E1175042001080E0520020E0E0E070003020E0E11790420010102050001117D0E05200101117D040001080E052002010808060002020E100A0400010A0E042001010A042000124D052002011C180B000212808512808512808505200101124D0420001229052002010E0E05000012808D0520011D050E042000123D072003011D05080805200012809105200101123D0520001180990420001D0E0420010E0E0500010E1D0E042001020E05000111450805000111250E042001081C040701120C08B77A5C561934E0890306114503061125030612100306124D0C0004122111251125112511250D0004011C10114510112510112509200301114511251125030000010A2004021C1251125511590801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F777301080100070100000000811901000400540E1146696C6C526F774D6574686F644E616D651246696C6C526F774874747052657175657374540E0F5461626C65446566696E6974696F6E3D537461747573436F646520494E542C20526573706F6E7365204E56415243484152284D4158292C2048656164657273204E56415243484152284D4158295455794D6963726F736F66742E53716C5365727665722E5365727665722E446174614163636573734B696E642C2053797374656D2E446174612C2056657273696F6E3D342E302E302E302C2043756C747572653D6E65757472616C2C205075626C69634B6579546F6B656E3D623737613563353631393334653038390A446174614163636573730100000054020F497344657465726D696E69737469630004010000000000000000005D46E36400000000020000001C0100008C3C00008C1E000052534453A26B087A272199439F09D90AE7828B6001000000433A5C55736572735C636C6572636A5C736F757263655C7265706F735C44617461626173655C417373656D626C79487474705C6F626A5C44656275675C417373656D626C79487474702E706462000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000D03D00000000000000000000EA3D0000002000000000000000000000000000000000000000000000DC3D0000000000000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF2500200010000000000000000000000000000001001000000018000080000000000000000000000000000001000100000030000080000000000000000000000000000001000000000048000000584000005C02000000000000000000005C0234000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100000000000000000000000000000000003F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B004BC010000010053007400720069006E006700460069006C00650049006E0066006F0000009801000001003000300030003000300034006200300000002C0002000100460069006C0065004400650073006300720069007000740069006F006E000000000020000000300008000100460069006C006500560065007200730069006F006E000000000030002E0030002E0030002E003000000042001100010049006E007400650072006E0061006C004E0061006D006500000041007300730065006D0062006C00790048007400740070002E0064006C006C00000000002800020001004C006500670061006C0043006F0070007900720069006700680074000000200000004A00110001004F0072006900670069006E0061006C00460069006C0065006E0061006D006500000041007300730065006D0062006C00790048007400740070002E0064006C006C0000000000340008000100500072006F006400750063007400560065007200730069006F006E00000030002E0030002E0030002E003000000038000800010041007300730065006D0062006C0079002000560065007200730069006F006E00000030002E0030002E0030002E00300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000C000000FC3D00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 

-- trust the assembly with sp_add_trusted_assembly
SET @hash = (SELECT TOP 1 hash FROM sys.trusted_assemblies WHERE description = 'AssemblyHttp')
IF @hash IS NOT NULL EXEC sp_drop_trusted_assembly @hash
DROP FUNCTION IF EXISTS dbo.HttpRequest
DROP ASSEMBLY IF EXISTS AssemblyHttp

SET @hash = HASHBYTES('SHA2_512', @clrBinary)
EXEC sp_add_trusted_assembly @hash, N'AssemblyHttp'

-- Create the assembly and the function associated
CREATE ASSEMBLY AssemblyHttp AUTHORIZATION [dbo] FROM @clrBinary WITH PERMISSION_SET = UNSAFE;

EXEC ('CREATE FUNCTION dbo.HttpRequest(@requestType AS VARCHAR(8), @url AS NVARCHAR(MAX), @headers AS NVARCHAR(MAX), @body AS NVARCHAR(MAX)) 
    RETURNS TABLE (StatusCode INT, Response NVARCHAR(MAX), Headers NVARCHAR(MAX)) AS EXTERNAL NAME [AssemblyHttp].UserDefinedFunctions.HttpRequest')
