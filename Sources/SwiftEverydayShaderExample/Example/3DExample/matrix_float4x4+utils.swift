import simd

extension matrix_float4x4 {
    static func perspectiveMatrix(
        fovyRadians fovy: Float32 = 65 * 3.141_592 / 180.0,
        aspectRatio: Float32, // w/h
        nearZ: Float32 = 0.1,
        farZ: Float32 = 100
    ) -> matrix_float4x4 {
        let yScale = 1 / tanf(fovy * 0.5)
        let xScale = yScale / aspectRatio
        let zScale = farZ / (nearZ - farZ)
        return matrix_float4x4(
            columns: (
                vector_float4(xScale, 0, 0, 0),
                vector_float4(0, yScale, 0, 0),
                vector_float4(0, 0, zScale, -1),
                vector_float4(0, 0, nearZ * zScale, 0)
            )
        )
    }

    static func rotationMatrix4x4(radians: Float32, axis: vector_float3) -> matrix_float4x4 {
        let unitAxis = normalize(axis)
        let cosTheta = cosf(radians)
        let sinTheta = sinf(radians)
        let oneMinusCosTheta = 1 - cosTheta

        let m11 = cosTheta + unitAxis.x * unitAxis.x * oneMinusCosTheta
        let m21 = unitAxis.y * unitAxis.x * oneMinusCosTheta + unitAxis.z * sinTheta
        let m31 = unitAxis.z * unitAxis.x * oneMinusCosTheta - unitAxis.y * sinTheta
        let m12 = unitAxis.x * unitAxis.y * oneMinusCosTheta - unitAxis.z * sinTheta
        let m22 = cosTheta + unitAxis.y * unitAxis.y * oneMinusCosTheta
        let m32 = unitAxis.z * unitAxis.y * oneMinusCosTheta + unitAxis.x * sinTheta
        let m13 = unitAxis.x * unitAxis.z * oneMinusCosTheta + unitAxis.y * sinTheta
        let m23 = unitAxis.y * unitAxis.z * oneMinusCosTheta - unitAxis.x * sinTheta
        let m33 = cosTheta + unitAxis.z * unitAxis.z * oneMinusCosTheta

        return matrix_float4x4(
            columns: (
                vector_float4(m11, m21, m31, 0),
                vector_float4(m12, m22, m32, 0),
                vector_float4(m13, m23, m33, 0),
                vector_float4(0, 0, 0, 1)
            )
        )
    }

    static func translationMatrix4x4(_ translationX: Float32, _ translationY: Float32, _ translationZ: Float32) -> matrix_float4x4 {
        return matrix_float4x4(
            columns: (
                vector_float4(1, 0, 0, 0),
                vector_float4(0, 1, 0, 0),
                vector_float4(0, 0, 1, 0),
                vector_float4(translationX, translationY, translationZ, 1)
            )
        )
    }
}

