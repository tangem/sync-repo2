//
//  TestData.swift
//  Tangem
//
//  Created by Yulia Moskaleva on 19/03/2018.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import Foundation

enum TestData: String {

    case rsk = "90000108CB180000000000058006312E323872000A027E200C8B81020025820407E3020F830452534B00840352534BA003524946A12A307832616363393537353866386235663538333437306261323635656236383561386634356663396435A20112864079753572D4DAAAF9543F5CE509BD3F4E22A1AF76B7ECE5C48F2951AF3180CF8178A1EB54A454C7DF12EA0F4CAB14ADCC6002BE1316F20C958B430EC4F1CB1F91034104C7D98A828A399E48643709ABBFAC6825ECED8E4B1D16761B0E356AA34B673D345AE8602E8418A9E269E80ECB53E671B6F1E833E838F8868CBA06D878AB1998C360410463169D2FED0A58A2EA87D13CC4E28B46B1E41ACBC3194397ED26446C3A2B995A1B87AEE581AC6AC49CFD1C7E931F94249EAB777CB79401E277F5802A0644C9A90804000F42406204000F424063040000000016102C5AFBD08001D5C64E966FF4AB23BC201710FD9EDBAA1FE29C0AD08698BC71A53E47614070D5E00216C4C321ED936F9692922513156B5B0956DA08A10D134A7D3633C985BF827D5C6A3D219D041070AC266DD7957F56F81789A92B047CAF5BE3EDC19D220F0100"
    case updatedSpec = "90000108CB100000000000038006312E323872000A027E210C5A8102001C820407E2090B830754414E47454D0084034254438640EF78A278D6EFCB87DA4D269FCE96DA420A4A520C7B1530397D4C2C7EC787C4996FFA80F4210528AEF90F9E99800CCB82388E932AD653A97EA08D5D6531B641D10341043E4071B7157F439DBA93A16EC3D000169BBA99775D323D5755155FCDF5FEEDDEE1C00FE6FE98C358F759EC891C6D725E1C1CB11CE4B1115BF608300B206D64F56041047A917B62D8929E9F0CE95499A21666188E4B7DA2EEEF43561B1F499DD4CF80C236132EA57D2BC1A3DC25BE5FF234AF66EE19BA34ED67AB7937B0FE3464A2509F0804000F42406204000F42406304000000001610EECBB8B2BD367689C58E3E284895CDCE171024FAEBF00836EFC586251C7838DD20D461409C668745966AF9310FB1402D01CEC73BDD9E5549768C2F1F9EEC7E476A599296016025A4327D0A4E92B65E69619530983AC99CDC365DE5B56FB32BA867AA53AC0F0100"
    case btcWallet = "90000108CB020000000139078006312E313972000C5A81020010820407E20507830754414E47454D0084034254438640EB32AE43D9C0D5DFB0268742C4C627C67022EBB8EE6A1E079198903B42ADDE9EF3041CD71D0DC067B2545D61B3168CBAB141F3F743461CD79C3087D3D9DBFB2003410451316D1A6DE66542BCF433A0BE7FEAC2B499FD66B2C1B253E4AFFD2CC3192FD45B8F228B8E662C77E534642372F63B9AD061259D0DD202E0A7612CFB85595C5C604104F71C39C9ECD664F56CFFB1F3045765A5EF81B08855C9AEA37B5D64A601E715E9BF26A4CD002CC94CD5246FCCC3F2F335AD63B7F834E969D9EA6A6B40070BB5616204000F42406304000000001610D08D22DA56475300D986434B675C571517102165CEEB05566FBBAECF894B304AA5D96140F3479C4E47F0CCC08B359E8300E197E03F27A5E86F63782E207117330DCC87B8485CA981BDE6A65DB8F882DDEAFAD21B35409C2D2C66AFB556EFA77D1A76731B0F0100"
    case btcNoWallet = "90000108CB020000000157048006312E313972000C5A81020010820407E20507830754414E47454D0084034254438640E1B02C61268D892B1BAA75C1D790EA6A6B6652BA38B09FB3A24682CD56F915C3F412EDEE1F71BFC40A37F0251E5FE276724AB0D329559FD60785B4FA8DE842A9034104B01565AFA1E39519FD089270F9812A8191F883C1EBC6B8AA27D516128A82580800603678CAABB32F957DBA1E82424776954716FF30995F6387392D821435D04F0F0100"
    case ethLoaded = "90000108FF00000000000251800A312E3238642053444B000A027E310C5E8102FFFF820407E20814830B54414E47454D2053444B00840345544886405B6E22E6293F7473FFE954A71755033AE567EDE33C40666C72FBDC879041490CD67BD7CC77E79801B6DE51EAE8EF2E1CCC1AF8414A9CD9590A6D2C0CA71A633B034104C68B2A1F3A652F05832CB7F85808A628EE81AB6B58E300923E0F101CB5A7D349352A0B596B712CD115B4F2FE0965F71016EA7DF9BC6D2B010A40C8B92766F4F0604104413E190DC2F18DC9AEF2199A3EFE145AAA361214623D1D53D7BCACE776DE113B8B8E8444433F9CCF8DF9673B28A03FDD6751A56F7C798A08AAB1C03B500F7EFC0804000186A062040001869C6304000000041610F9C4A95FACAF5930B10E6AAE51FCF3F617101415B4C8B2937E26ADB154F2FC03FFE5614058785CDF909D46E44035D945015057D9BEA118302FC1B6BEC1B28A6815E5E84CD4A06FC258C76385397731CA780A136F34C5CC8CB6C06557853EA876BFBFADA10F0100"
    case ethWallet = "90000108AA000000000059420C5E81020004820407E20708830B54414E47454D2053444B008403455448864070E97043CE12C249B45B1D468F10FD75B12E5B971C13A405259AC98048D69F4E62A5D321260134DCA39C7D633CC6474F600DCE70641D7B646FF652C0E5A4B1DD034104DDF47FBBEBC50BB21AE97971F4DA32EFFF0518DBA702F37824E195E8B5E98B0E9FD0FB1DCCD2289F68A0667CBADD80E3CEDAF44D2DA2E74021411F82786FB062604104081926126210F74F7C5E20A19F25168219BF787D0F6798CCE261FFF31FED1A5B318AC133DEA7514EE3E2D033C75ADF79EF797F6FCF80D12E593D4F4FC09AE6D86204000F424016100CB142D2683A35A06F7194E346BE83A21710D6E0F8E850A60A2BD01DB5B2B0615F8B614059DC847764F76BA8342114E01471D74F8D50E8F0E35B151B4403E78EEB8BAB5C33378CD7DF9E839C210719BA33595DC439228AF013E95DC5581190E3C16B7BED0F0100"
    case seed = "90000108CB030000000000028006312E323472000A027E300C9381020012820407E20616830B5355504552424C4F4F4D008403455448A00453454544A12A307834453742643838453339393666343845326132344431354533376341344330324234443133346432A201128640A8A2C072306C3C3302B4DEBDBAEF9FCC0483B6BB588AB6284FD7A2CC9B144798B510404B96D5F485238758D4CAB81ABACAC1AAAD8B40865FF09E80AB648801DE0341045195CC18D4852643BA1FE088405E7DEF0A94EEDB41892E340E4C3CFCF7FAE7569CDEA16050D6BDE373EEC3B438B7D7C57BAB4F815302C2B768692E091616D7DC6041040690E1BEB95361BE2D4F2BB05CF48E7EAC57FD82005EC39D703925E7A2BD60509BB194716969A44EFAD3BF2375541FA42D930CC5B94464B972441527B5229D3D0804000F42406204000F4240630400000000161088FDD29ED228C5F5D0A93FAD269D679C1710C7F69AD955DFE750D1C634769545BBC3614045CA1BFF713F963B9647A957A1F2314392E39492F7288C1E1F01CF0923918DBDDEE719302FAEBEF161CE0C05F830E913032A1B55E274A15C14DC11851CAE58900F0100"
    case seed_my = "90000108AA000000000059420C9581020004820407E20708830B54414E47454D2053444B008403455448A00453454544A12C3078344537426438384533393936663438453261323444313545333763413443303242344431333464320A0AA201128640D68E013EC4C524131563E14E5B81364A1B9A6A586DA578E58F5BCD5C583FB02C3F4798A2B949F84A5BA8488BCCFB731EB5B3D78A662695134C5B3CBFE3A113B6034104E1E5E380C18911BE91795C558BBBEB06E02BC625BC073A4806B1D53F97F31A8F8D9C895C04B668371927C9A70D3B1B39522BEEEE743D7488A7A3F872B404E16260410421AC8283BC8FDD354A78278BE17C7D3971084ADA69C80DE224F2F3BE206B73ACF543BB1E209FF2C68FC482C537661FF0C720DA580241E00EAB0AF271B4EE3A196204000F42401610CFDBC5D36A5CA939F7A2097F52DAA6841710B61A049575E4810E98F7864F0736E1CD61403AECD64FD1C43EF9CFFEF733C6954110F39EDA7D18B152E2D6C5033789B059F1F05459D9E2269DBDB74B3EC23DC668ACA9834E8636937B6BB46D467FA9842A030F0100"
    case ert = "90000108AA000000000059420C9281020004820407E20708830B54414E47454D2053444B008403455448A003455254A12A307845323963354235323335393031363537393542424437643532333639633238393542313838343166A2011286409763548F809CE710F0BD3D044878E60DC161EFC01B26311BC3C74D391946225AF23E0162349476CA70AF78C2C4EB6725059932997257E0CAF1C53EE957FD713F03410474DDA5D790B8D6022BD32F050AE945271DADB5BB0EDFF307A9CC15B98F032AB6D3B7673F3BF7E9652FFF11E4200C784B2FD9D044A4F76B0ACA5C2F62B419911E604104EDEC85C3FEF50D3E818EFCDE7A27BC3E2346A54AE8AB6304B85FDB01DD0D235ECC5EC886C5F23B78A74420C7AC211D5AAE6C75ACA1254707BCE52340FD3939C56204000F42401610E4BA3B295CDE74F87502F54924E459C81710D24A7D915B0AD5FB2079D66D7F0C9AFA614058F74CD867A157C733AEE86EBF7CA2F5B6889B135814FADF5F660572F6A6C99EB39BC114E11CC3816DD1DDA1B418706DC38EDF255F317AF7664D2EFA3D20747B0F0100"
    case qlear = "90000108DB017000000000078006312E323872000A027E200C738102FF07820407E20814830B4359434C455B6269745D008403455448A003434C45A10B4E6F7420646566696E6564A20112864005A94E6686B54F0B8CE87B205BBF78288960A4FCC3F41FF07C55642CCA38A3C1AA8B59DCDA4502C2062D39A471B45EBFEB6774A6144811A3B7C36F4BCC829E660341042887D3FA14129EE7668FC1E5EE20B27EBF9222AA92942CC456B440636C13AD206A1E4A15EEB4D7C6375C73E1EA567F38F6F7927A43B4F32E40B020AA39659A46604104146954DFACED84AD66B798437AFE35E96D86E9CE17346F52BBD86C8EDAEE704436C9CEA325E8386B7105D40FFE2CD49277EE4F06C197E3A166319F3CB6A4178D0804000F42406204000F424063040000000016102E21581C2FFD6AC457F6F52E676150591710C84248C0C8418638C6B934B1CEA2BB8E61402D21D123ECB0656F8553E10AC7ED5E666D86C85E5FB77091F7427D595944C35441705A3B33AC043D8E7A34429A82E2B241BDB69F6C83F9B56111B44031C8F5E70F0100"
    
    case whirl = "90000108CB110000000000028006312E323872000A027E200C638102001E820407E20A018306576869726C008403455448A00357524CA100A2010086405489F96DEFA724FA0C533F8BBDD6D1BC165FD1069E482B33FA60748D7B2C8AAA277D4D98935A5E213BE67E4A85371A41454928E24BBB63B6BD6FFE4895881F54034104D6DE356A3F7175BE080405E284B726E90AE482A3ED1C9108937F74E8595FD9B838F3629192DABA38E798C2268B65B7EA907FD1CF30C63A861193BD45DD0DDB96604104047B234B9BA1C5401329674B9F51D029BE4ABEAEDE392D0233B193C86B0A2E97CAF350F371EEFDE99BB48FB8ADF7CF2879245982C8A1CEB2EAB668CE92CE15980804000F42406204000F424063040000000016104B86DD24A6CA0C3FDDC5707230477F491710BF546E03F40B77A8F34E3BA6172D7C6B61404329F65BC72861B966B3411888F41318913EA6ACFB34F98B0ACDDECC6C553E53FA0D27E4A333D0D0A98CA5CA37453C57066331DC10D02B1C14DE48E56C7C38CC0F0100"
    
    case pinWallet = "6A86"
    case wrongTLV = "90000108BB000100403161800C6181020003820407E2021A830D534D4152542043415348204147840345544834"
}
