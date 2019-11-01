//
//  UtilsTest.swift
//  TangemSdkTests
//
//  Created by Alexander Osokin on 31.10.2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//
import XCTest
@testable import TangemSdk

class DataExtensionTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSha256() {
        let testData = CryptoUtils.generateRandomBytes(count: 256)!
        let shaCryptoKit =  testData.sha256()
        let shaOld = testData.sha256Old()
        XCTAssert(shaCryptoKit == shaOld)
    }
    
    func testSha512() {
        let testData = CryptoUtils.generateRandomBytes(count: 256)!
        let shaCryptoKit =  testData.sha512()
        let shaOld = testData.sha512Old()
        XCTAssert(shaCryptoKit == shaOld)
    }
    
    func testSha256CryptoKitPerfomance() {
        let testData = CryptoUtils.generateRandomBytes(count: 256)!
        measure {
            _ = testData.sha256()
        }
    }
    
    func testSha256OldPerfomance() {
        let testData = CryptoUtils.generateRandomBytes(count: 256)!
        measure {
            _ = testData.sha256Old()
        }
    }
    
    func testBytesConversion() {
        let testData = Data(repeating: UInt8(2), count: 3)
        let testArray = Array.init(repeating: UInt8(2), count: 3)
        XCTAssert(testData.bytes == testArray)
    }
    
    func testToDateString() {
        let testData = Data(hex: "07E2071B")
        let testDate = "Jul 27, 2018"
        XCTAssert(testDate == testData.toDateString())
        
        let testData1 = Data(hex: "07E2071B1E")
        let testDate1 = "Jul 27, 2018"
        XCTAssert(testDate1 == testData1.toDateString())
        
        let testData2 = Data(hex: "07E207")
        let testDate2 = ""
        XCTAssert(testDate2 == testData2.toDateString())
    }
    
    func testFromHexConversion() {
        let testData = Data([UInt8(0x07),UInt8(0xE2),UInt8(0x07),UInt8(0x1B)])
        XCTAssert(testData == Data(hex: "07E2071B"))
    }
    
    func testToHexConversion() {
        let testData = Data([UInt8(0x07),UInt8(0xE2),UInt8(0x07),UInt8(0x1B)])
        let hex = testData.toHexString()
        XCTAssert(hex == "07E2071B")
    }
    
    func testToUtf8Conversion() {
        let testData = Data(hex: "736563703235366B3100")
        let testString = "secp256k1"
        let converted = testData.toUtf8String()
        XCTAssertNotNil(converted)
        XCTAssert(converted! == testString)
    }
    
    func testToIntConversion() {
        let testData = Data(hex: "00026A03")
        let intData = 158211
        let converted = testData.toInt()
        XCTAssert(converted == intData)
    }
}
