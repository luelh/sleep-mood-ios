//
//  ColorPickerView.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/4/25.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ColorPicker("색상 선택", selection: $selectedColor)
                .padding()
                .navigationTitle("색상 선택")
                .navigationBarItems(trailing: Button("완료") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
} 
