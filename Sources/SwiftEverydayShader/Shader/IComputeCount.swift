import simd

public protocol IComputeCount { }

extension UInt32: IComputeCount { }
extension Int32: IComputeCount { }
extension vector_int2: IComputeCount { }
extension vector_int3: IComputeCount { }
