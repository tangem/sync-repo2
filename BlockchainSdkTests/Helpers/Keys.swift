import Foundation
import TangemSdk

enum Keys {
    enum AddressesKeys {
        static let secpPrivKey = Data(hexString: "83686EF30173D2A05FD7E2C8CB30941534376013B903A2122CF4FF3E8668355A")
        static let secpDecompressedKey = Data(hexString: "0441DCD64B5F4A039FC339A16300A833A883B218909F2EBCAF3906651C76842C45E3D67E8D2947E6FEE8B62D3D3B6A4D5F212DA23E478DD69A2C6CCC851F300D80")
        static let secpCompressedKey = Data(hexString: "0241DCD64B5F4A039FC339A16300A833A883B218909F2EBCAF3906651C76842C45")
        static let edKey = Data(hex: "9FE5BB2CC7D83C1DA10845AFD8A34B141FD8FD72500B95B1547E12B9BB8AAC3D")
    }

    enum Secp256k1 {
        static let publicKey = Data(hexString: "039BBD8C96ADA3D42648FBE52FB40F3DAE106E7552EFE42A3F51583300AD5E74AB")
    }
}
