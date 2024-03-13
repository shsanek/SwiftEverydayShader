import SwiftUI
import simd
import SwiftEverydayShader

struct MainView: View {
    @State var currentExample: IExample? = nil

    let renderLoop: MainRenderLoop
    let metalView: MetalView

    let examples: [IExample]

    var body: some View {
        NavigationSplitView {
            List(examples, id: \.name) { example in
                Button {
                    currentExample = example
                    renderLoop.example = example
                } label: {
                    Text(example.name)
                }.buttonStyle(.plain)
            }
        } detail: {
            if currentExample != nil {
                SwiftUIView {
                    metalView
                }
            } else {
                Text("Select example")
            }
        }
    }
}

