//
//  MainView.swift
//  
//
//  Created by Aleksei Tiurnin on 03.07.2024.
//

import SwiftUI
import PhotoPicker
public struct MainView: View {
    
    @EnvironmentObject private var textParameters: TextParameters
    
    @ObservedObject private var viewModel: MainViewModel
    
    @State private var isShowPhotoPicker: Bool = false
    @State private var isShowFontPicker: Bool = false
    @State private var isShowDatePicker: Bool = false
    
    private let calendarManager: CalendarManager
    
    public init(calendarManager: CalendarManager) {
        self.calendarManager = calendarManager
        viewModel = MainViewModel(date: Date(), calendarManager: calendarManager)
    }
    
    public var body: some View {
        ZStack {
            if  let data = viewModel.image,
                let uiimage = UIImage.init(data: data) {
                ImageZoomDragView(image: Image(uiImage: uiimage))
                    .onTapGesture {
                        self.isShowPhotoPicker.toggle()
                    }
            }
            VStack(alignment: .center, spacing: 4 * textParameters.scale) {
                Text(viewModel.month.name)
                    .font(
                        .custom(
                            textParameters.font,
                            size: 24 * textParameters.scale))
                    .foregroundColor(textParameters.mainTextColor)
                    .clipped()
                    .shadow(
                        color: textParameters.shadowColor,
                        radius: 2)
                    .onTapGesture {
                        isShowDatePicker = true
                    }
                HStack(spacing: 8) {
                    if viewModel.showWeekNumber {
                        WeekNumberView(data: " ")
                    }
                    WeekHeaderView(data: viewModel.month.weekSymbols)
                }
                VStack(spacing: 4 * textParameters.scale) {
                    ForEach(viewModel.month.values, id: \.number) { element in
                        HStack(spacing: 8) {
                            if viewModel.showWeekNumber {
                                WeekNumberView(data: "\(element.number)")
                            }
                            WeekView(
                                data: element.values)
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowFontPicker.toggle()
                }
            }
        }
        .sheet(isPresented: $isShowPhotoPicker) {
            PhotoPicker(isPresented: $isShowPhotoPicker, imageData: $viewModel.image)
        }
        .sheet(isPresented: $isShowFontPicker) {
            TextParametersEditorView(
                isBlurred: $viewModel.isBlurred)
        }
        .sheet(isPresented: $isShowDatePicker) {
            DateEditorView(
                current: viewModel.current,
                date: $viewModel.date,
                showWeekNumber: $viewModel.showWeekNumber,
                calendarManager: calendarManager)
        }
        .onChange(of: viewModel.date) { newValue in
            viewModel.updateMonth()
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    MainView(calendarManager: CalendarManager(option: .en))
        .environmentObject(TextParameters())
}
