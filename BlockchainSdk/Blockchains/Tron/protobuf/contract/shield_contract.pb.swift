// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: core/contract/shield_contract.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
@preconcurrency import SwiftProtobuf    // TODO: Andrey Fedorov - Remove after migration to Swift 6 structured concurrency (IOS-8369)

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct Protocol_AuthenticationPath: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var value: [Bool] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_MerklePath: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var authenticationPaths: [Protocol_AuthenticationPath] = []

  var index: [Bool] = []

  var rt: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_OutputPoint: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var hash: Data = Data()

  var index: Int32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_OutputPointInfo: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var outPoints: [Protocol_OutputPoint] = []

  var blockNum: Int32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_PedersenHash: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var content: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_IncrementalMerkleTree: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var left: Protocol_PedersenHash {
    get {return _left ?? Protocol_PedersenHash()}
    set {_left = newValue}
  }
  /// Returns true if `left` has been explicitly set.
  var hasLeft: Bool {return self._left != nil}
  /// Clears the value of `left`. Subsequent reads from it will return its default value.
  mutating func clearLeft() {self._left = nil}

  var right: Protocol_PedersenHash {
    get {return _right ?? Protocol_PedersenHash()}
    set {_right = newValue}
  }
  /// Returns true if `right` has been explicitly set.
  var hasRight: Bool {return self._right != nil}
  /// Clears the value of `right`. Subsequent reads from it will return its default value.
  mutating func clearRight() {self._right = nil}

  var parents: [Protocol_PedersenHash] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _left: Protocol_PedersenHash? = nil
  fileprivate var _right: Protocol_PedersenHash? = nil
}

struct Protocol_IncrementalMerkleVoucher: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var tree: Protocol_IncrementalMerkleTree {
    get {return _tree ?? Protocol_IncrementalMerkleTree()}
    set {_tree = newValue}
  }
  /// Returns true if `tree` has been explicitly set.
  var hasTree: Bool {return self._tree != nil}
  /// Clears the value of `tree`. Subsequent reads from it will return its default value.
  mutating func clearTree() {self._tree = nil}

  var filled: [Protocol_PedersenHash] = []

  var cursor: Protocol_IncrementalMerkleTree {
    get {return _cursor ?? Protocol_IncrementalMerkleTree()}
    set {_cursor = newValue}
  }
  /// Returns true if `cursor` has been explicitly set.
  var hasCursor: Bool {return self._cursor != nil}
  /// Clears the value of `cursor`. Subsequent reads from it will return its default value.
  mutating func clearCursor() {self._cursor = nil}

  var cursorDepth: Int64 = 0

  var rt: Data = Data()

  var outputPoint: Protocol_OutputPoint {
    get {return _outputPoint ?? Protocol_OutputPoint()}
    set {_outputPoint = newValue}
  }
  /// Returns true if `outputPoint` has been explicitly set.
  var hasOutputPoint: Bool {return self._outputPoint != nil}
  /// Clears the value of `outputPoint`. Subsequent reads from it will return its default value.
  mutating func clearOutputPoint() {self._outputPoint = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _tree: Protocol_IncrementalMerkleTree? = nil
  fileprivate var _cursor: Protocol_IncrementalMerkleTree? = nil
  fileprivate var _outputPoint: Protocol_OutputPoint? = nil
}

struct Protocol_IncrementalMerkleVoucherInfo: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var vouchers: [Protocol_IncrementalMerkleVoucher] = []

  var paths: [Data] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_SpendDescription: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var valueCommitment: Data = Data()

  /// merkle root
  var anchor: Data = Data()

  /// used for check double spend
  var nullifier: Data = Data()

  /// used for check spend authority signature
  var rk: Data = Data()

  var zkproof: Data = Data()

  var spendAuthoritySignature: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_ReceiveDescription: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var valueCommitment: Data = Data()

  var noteCommitment: Data = Data()

  /// for Encryption
  var epk: Data = Data()

  /// Encryption for incoming, decrypt it with ivk
  var cEnc: Data = Data()

  /// Encryption for audit, decrypt it with ovk
  var cOut: Data = Data()

  var zkproof: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_ShieldedTransferContract: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// transparent address
  var transparentFromAddress: Data = Data()

  var fromAmount: Int64 = 0

  var spendDescription: [Protocol_SpendDescription] = []

  var receiveDescription: [Protocol_ReceiveDescription] = []

  var bindingSignature: Data = Data()

  /// transparent address
  var transparentToAddress: Data = Data()

  /// the amount to transparent to_address
  var toAmount: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "protocol"

extension Protocol_AuthenticationPath: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".AuthenticationPath"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "value"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedBoolField(value: &self.value) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.value.isEmpty {
      try visitor.visitPackedBoolField(value: self.value, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_AuthenticationPath, rhs: Protocol_AuthenticationPath) -> Bool {
    if lhs.value != rhs.value {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_MerklePath: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MerklePath"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "authentication_paths"),
    2: .same(proto: "index"),
    3: .same(proto: "rt"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.authenticationPaths) }()
      case 2: try { try decoder.decodeRepeatedBoolField(value: &self.index) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.rt) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.authenticationPaths.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.authenticationPaths, fieldNumber: 1)
    }
    if !self.index.isEmpty {
      try visitor.visitPackedBoolField(value: self.index, fieldNumber: 2)
    }
    if !self.rt.isEmpty {
      try visitor.visitSingularBytesField(value: self.rt, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_MerklePath, rhs: Protocol_MerklePath) -> Bool {
    if lhs.authenticationPaths != rhs.authenticationPaths {return false}
    if lhs.index != rhs.index {return false}
    if lhs.rt != rhs.rt {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_OutputPoint: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".OutputPoint"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "hash"),
    2: .same(proto: "index"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.hash) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.index) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.hash.isEmpty {
      try visitor.visitSingularBytesField(value: self.hash, fieldNumber: 1)
    }
    if self.index != 0 {
      try visitor.visitSingularInt32Field(value: self.index, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_OutputPoint, rhs: Protocol_OutputPoint) -> Bool {
    if lhs.hash != rhs.hash {return false}
    if lhs.index != rhs.index {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_OutputPointInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".OutputPointInfo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "out_points"),
    2: .standard(proto: "block_num"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.outPoints) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.blockNum) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.outPoints.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.outPoints, fieldNumber: 1)
    }
    if self.blockNum != 0 {
      try visitor.visitSingularInt32Field(value: self.blockNum, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_OutputPointInfo, rhs: Protocol_OutputPointInfo) -> Bool {
    if lhs.outPoints != rhs.outPoints {return false}
    if lhs.blockNum != rhs.blockNum {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_PedersenHash: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PedersenHash"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "content"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.content) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.content.isEmpty {
      try visitor.visitSingularBytesField(value: self.content, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_PedersenHash, rhs: Protocol_PedersenHash) -> Bool {
    if lhs.content != rhs.content {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_IncrementalMerkleTree: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".IncrementalMerkleTree"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "left"),
    2: .same(proto: "right"),
    3: .same(proto: "parents"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._left) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._right) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.parents) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._left {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._right {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !self.parents.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.parents, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_IncrementalMerkleTree, rhs: Protocol_IncrementalMerkleTree) -> Bool {
    if lhs._left != rhs._left {return false}
    if lhs._right != rhs._right {return false}
    if lhs.parents != rhs.parents {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_IncrementalMerkleVoucher: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".IncrementalMerkleVoucher"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "tree"),
    2: .same(proto: "filled"),
    3: .same(proto: "cursor"),
    4: .standard(proto: "cursor_depth"),
    5: .same(proto: "rt"),
    10: .standard(proto: "output_point"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._tree) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.filled) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._cursor) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.cursorDepth) }()
      case 5: try { try decoder.decodeSingularBytesField(value: &self.rt) }()
      case 10: try { try decoder.decodeSingularMessageField(value: &self._outputPoint) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._tree {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.filled.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.filled, fieldNumber: 2)
    }
    try { if let v = self._cursor {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if self.cursorDepth != 0 {
      try visitor.visitSingularInt64Field(value: self.cursorDepth, fieldNumber: 4)
    }
    if !self.rt.isEmpty {
      try visitor.visitSingularBytesField(value: self.rt, fieldNumber: 5)
    }
    try { if let v = self._outputPoint {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 10)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_IncrementalMerkleVoucher, rhs: Protocol_IncrementalMerkleVoucher) -> Bool {
    if lhs._tree != rhs._tree {return false}
    if lhs.filled != rhs.filled {return false}
    if lhs._cursor != rhs._cursor {return false}
    if lhs.cursorDepth != rhs.cursorDepth {return false}
    if lhs.rt != rhs.rt {return false}
    if lhs._outputPoint != rhs._outputPoint {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_IncrementalMerkleVoucherInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".IncrementalMerkleVoucherInfo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "vouchers"),
    2: .same(proto: "paths"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.vouchers) }()
      case 2: try { try decoder.decodeRepeatedBytesField(value: &self.paths) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.vouchers.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.vouchers, fieldNumber: 1)
    }
    if !self.paths.isEmpty {
      try visitor.visitRepeatedBytesField(value: self.paths, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_IncrementalMerkleVoucherInfo, rhs: Protocol_IncrementalMerkleVoucherInfo) -> Bool {
    if lhs.vouchers != rhs.vouchers {return false}
    if lhs.paths != rhs.paths {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_SpendDescription: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SpendDescription"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "value_commitment"),
    2: .same(proto: "anchor"),
    3: .same(proto: "nullifier"),
    4: .same(proto: "rk"),
    5: .same(proto: "zkproof"),
    6: .standard(proto: "spend_authority_signature"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.valueCommitment) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.anchor) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.nullifier) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.rk) }()
      case 5: try { try decoder.decodeSingularBytesField(value: &self.zkproof) }()
      case 6: try { try decoder.decodeSingularBytesField(value: &self.spendAuthoritySignature) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.valueCommitment.isEmpty {
      try visitor.visitSingularBytesField(value: self.valueCommitment, fieldNumber: 1)
    }
    if !self.anchor.isEmpty {
      try visitor.visitSingularBytesField(value: self.anchor, fieldNumber: 2)
    }
    if !self.nullifier.isEmpty {
      try visitor.visitSingularBytesField(value: self.nullifier, fieldNumber: 3)
    }
    if !self.rk.isEmpty {
      try visitor.visitSingularBytesField(value: self.rk, fieldNumber: 4)
    }
    if !self.zkproof.isEmpty {
      try visitor.visitSingularBytesField(value: self.zkproof, fieldNumber: 5)
    }
    if !self.spendAuthoritySignature.isEmpty {
      try visitor.visitSingularBytesField(value: self.spendAuthoritySignature, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_SpendDescription, rhs: Protocol_SpendDescription) -> Bool {
    if lhs.valueCommitment != rhs.valueCommitment {return false}
    if lhs.anchor != rhs.anchor {return false}
    if lhs.nullifier != rhs.nullifier {return false}
    if lhs.rk != rhs.rk {return false}
    if lhs.zkproof != rhs.zkproof {return false}
    if lhs.spendAuthoritySignature != rhs.spendAuthoritySignature {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_ReceiveDescription: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ReceiveDescription"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "value_commitment"),
    2: .standard(proto: "note_commitment"),
    3: .same(proto: "epk"),
    4: .standard(proto: "c_enc"),
    5: .standard(proto: "c_out"),
    6: .same(proto: "zkproof"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.valueCommitment) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.noteCommitment) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.epk) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.cEnc) }()
      case 5: try { try decoder.decodeSingularBytesField(value: &self.cOut) }()
      case 6: try { try decoder.decodeSingularBytesField(value: &self.zkproof) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.valueCommitment.isEmpty {
      try visitor.visitSingularBytesField(value: self.valueCommitment, fieldNumber: 1)
    }
    if !self.noteCommitment.isEmpty {
      try visitor.visitSingularBytesField(value: self.noteCommitment, fieldNumber: 2)
    }
    if !self.epk.isEmpty {
      try visitor.visitSingularBytesField(value: self.epk, fieldNumber: 3)
    }
    if !self.cEnc.isEmpty {
      try visitor.visitSingularBytesField(value: self.cEnc, fieldNumber: 4)
    }
    if !self.cOut.isEmpty {
      try visitor.visitSingularBytesField(value: self.cOut, fieldNumber: 5)
    }
    if !self.zkproof.isEmpty {
      try visitor.visitSingularBytesField(value: self.zkproof, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_ReceiveDescription, rhs: Protocol_ReceiveDescription) -> Bool {
    if lhs.valueCommitment != rhs.valueCommitment {return false}
    if lhs.noteCommitment != rhs.noteCommitment {return false}
    if lhs.epk != rhs.epk {return false}
    if lhs.cEnc != rhs.cEnc {return false}
    if lhs.cOut != rhs.cOut {return false}
    if lhs.zkproof != rhs.zkproof {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_ShieldedTransferContract: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ShieldedTransferContract"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "transparent_from_address"),
    2: .standard(proto: "from_amount"),
    3: .standard(proto: "spend_description"),
    4: .standard(proto: "receive_description"),
    5: .standard(proto: "binding_signature"),
    6: .standard(proto: "transparent_to_address"),
    7: .standard(proto: "to_amount"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.transparentFromAddress) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.fromAmount) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.spendDescription) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.receiveDescription) }()
      case 5: try { try decoder.decodeSingularBytesField(value: &self.bindingSignature) }()
      case 6: try { try decoder.decodeSingularBytesField(value: &self.transparentToAddress) }()
      case 7: try { try decoder.decodeSingularInt64Field(value: &self.toAmount) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.transparentFromAddress.isEmpty {
      try visitor.visitSingularBytesField(value: self.transparentFromAddress, fieldNumber: 1)
    }
    if self.fromAmount != 0 {
      try visitor.visitSingularInt64Field(value: self.fromAmount, fieldNumber: 2)
    }
    if !self.spendDescription.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.spendDescription, fieldNumber: 3)
    }
    if !self.receiveDescription.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.receiveDescription, fieldNumber: 4)
    }
    if !self.bindingSignature.isEmpty {
      try visitor.visitSingularBytesField(value: self.bindingSignature, fieldNumber: 5)
    }
    if !self.transparentToAddress.isEmpty {
      try visitor.visitSingularBytesField(value: self.transparentToAddress, fieldNumber: 6)
    }
    if self.toAmount != 0 {
      try visitor.visitSingularInt64Field(value: self.toAmount, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_ShieldedTransferContract, rhs: Protocol_ShieldedTransferContract) -> Bool {
    if lhs.transparentFromAddress != rhs.transparentFromAddress {return false}
    if lhs.fromAmount != rhs.fromAmount {return false}
    if lhs.spendDescription != rhs.spendDescription {return false}
    if lhs.receiveDescription != rhs.receiveDescription {return false}
    if lhs.bindingSignature != rhs.bindingSignature {return false}
    if lhs.transparentToAddress != rhs.transparentToAddress {return false}
    if lhs.toAmount != rhs.toAmount {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
