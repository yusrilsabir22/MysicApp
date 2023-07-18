//
//  ButtonPressAction.swift
//  mysic
//
//  Created by mac on 20/06/23.
//

import Foundation
import SwiftUI
import Combine

struct ButtonPress: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({_ in
                        onPress()
                    })
                    .onEnded({_ in
                        onRelease()
                    })
            )
    }
}

struct JumpyEffect: GeometryEffect {
    let offset: Double
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let trans = (value + offset * (pow(5, value - 1/pow(value, 5))))
        let transform = CGAffineTransform(translationX: size.width * 0.5, y: size.height * 0.5)
            .scaledBy(x: trans, y: trans)
            .translatedBy(x: -size.width * 0.5, y: -size.height * 0.5)
        return ProjectionTransform(transform)
    }
}

struct TextFieldFocused: ViewModifier {
    @FocusState private var focused: Bool
        
    init() {
        self.focused = false
    }
    
    func body(content: Content) -> some View {
        content
            .focused($focused)
            .onAppear {
                focused = true
            }
    }
}


extension View {
    func pressEvent(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(ButtonPress(onPress: { onPress() }, onRelease: { onRelease() }))
    }
    
    func jumpyEffect(offset: Double, value: Double) -> some View {
        modifier(JumpyEffect(offset: offset, value: value))
    }
    
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
          .Merge(
            NotificationCenter
              .default
              .publisher(for: UIResponder.keyboardWillShowNotification)
              .map { _ in true },
            NotificationCenter
              .default
              .publisher(for: UIResponder.keyboardWillHideNotification)
              .map { _ in false })
          .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
          .eraseToAnyPublisher()
    }
//    
//    @ViewBuilder
//    func focused() -> some View {
//        if #available(iOS 15.0, *) {
//            self.modifier(TextFieldFocused())
//        } else {
//            self
//        }
//    }
        
}
