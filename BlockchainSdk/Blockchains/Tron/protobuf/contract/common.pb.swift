// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: core/contract/common.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum Protocol_ResourceCode: SwiftProtobuf.Enum, Swift.CaseIterable {
  typealias RawValue = Int
  case bandwidth // = 0
  case energy // = 1
  case tronPower // = 2
  case UNRECOGNIZED(Int)

  init() {
    self = .bandwidth
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .bandwidth
    case 1: self = .energy
    case 2: self = .tronPower
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .bandwidth: return 0
    case .energy: return 1
    case .tronPower: return 2
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [Protocol_ResourceCode] = [
    .bandwidth,
    .energy,
    .tronPower,
  ]

}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension Protocol_ResourceCode: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "BANDWIDTH"),
    1: .same(proto: "ENERGY"),
    2: .same(proto: "TRON_POWER"),
  ]
}
