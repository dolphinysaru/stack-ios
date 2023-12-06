//
//  ShortcutWidget.swift
//  ShortcutWidget
//
//  Created by jedmin on 2022/03/03.
//

import WidgetKit
import SwiftUI
import Localize_Swift

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct ShortcutWidgetEntryView : View {
    var entry: SimpleEntry
//    let budget = Budget.load().totalExpend
    let budgetPrice = UserDefaults(suiteName: appGroupName)?.double(forKey: UserDefault.budget_price) ?? 0
    let totalExpend = UserDefaults(suiteName: appGroupName)?.double(forKey: UserDefault.budget_totalspend) ?? 0
    
    @State var progressValue: Float = Float((UserDefaults(suiteName: appGroupName)?.double(forKey: UserDefault.budget_totalspend) ?? 0) / (UserDefaults(suiteName: appGroupName)?.double(forKey: UserDefault.budget_price) ?? 0))
        
    var body: some View {
        VStack {
            ProgressBar(progress: self.$progressValue)
                                .padding()
            
            Text("\(CurrencyManager.currencySymbol) " + "\(UserDefaults(suiteName: appGroupName)?.double(forKey: UserDefault.budget_totalspend) ?? 0)".price())
                .bold()
            
            Text("/ " + "\(CurrencyManager.currencySymbol) " + "\(budgetPrice)".price())
                .font(.system(size: 13)).foregroundColor(.secondary)
        }
        .padding(6)
        .conditionalContainerBackground()
    }
}


extension View {
    @ViewBuilder
    func conditionalContainerBackground() -> some View {
        if #available(iOS 17, *) {
            self.containerBackground(.black, for: .widget)
        } else {
            self
        }
    }
}

struct ProgressBar: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

//            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
//                .font(.largeTitle)
//                .bold()
        }
    }
}


@main
struct ShortcutWidget: Widget {
    let kind: String = "Stack Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ShortcutWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("input_price_title".localized())
        .description("widget_description".localized())
        .supportedFamilies([.systemSmall])
    }
}

struct ShortcutWidget_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
