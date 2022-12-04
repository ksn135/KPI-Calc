//
//  ContentView.swift
//  KPI Calc
//
//  Created by Serg Kalachev on 01.12.2022.
//

import SwiftUI
import Combine
import FloatingLabelTextFieldStyle

struct ContentView: View {
  enum Field {
    case cost
    case expenses
    case nbOfMasters
    case avgNbOfViews
    case avgTimeSpand
  }
    
  @State private var cost = 0.0
  @State private var expenses = 0.0
  @State private var nbOfMasters : Int = 0
  @State private var avgNbOfViews = 0.0
  @State private var avgTimeSpand = 0.0
  
  @FocusState private var focusedField: Field?

  @State private var showingBox = false

  private let KPI_TRESHOLD: Double = 0.78

  @State private var updater = false

  let rubNumberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.locale =  Locale(identifier: "ru_RU")
    return numberFormatter
  }()

  let numNumberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.locale =  Locale(identifier: "ru_RU")
    return numberFormatter
  }()
  
  func buildVersion() -> String {
      var result: String = "v???"
      if let infoDictionary = Bundle.main.infoDictionary {
          let version = infoDictionary["CFBundleShortVersionString"] as? String
          let build = infoDictionary[kCFBundleVersionKey as String] as? String
          if let version = version, let build = build {
              result = "v\(version) (\(build))"
          }
      }
      return result
  }

  var kpi: Double {
    let divider = Double(nbOfMasters) /* masterCost*/ * avgNbOfViews * avgTimeSpand
    if (divider <= 0) {
      return 0
    }
    return (cost + expenses) / divider
  }

  func recalculate(recalculateField: Field) -> Void {
    switch recalculateField {
    case .expenses:
      expenses = KPI_TRESHOLD * Double(nbOfMasters) * avgNbOfViews * avgTimeSpand - cost
    case .nbOfMasters:
      let rez : Double = (expenses + cost) / KPI_TRESHOLD * avgNbOfViews * avgTimeSpand
      nbOfMasters = 1 + Int(ceil(rez))
    case .avgNbOfViews:
       avgNbOfViews = (expenses + cost) / KPI_TRESHOLD * avgTimeSpand * Double(nbOfMasters)
    case .avgTimeSpand:
      avgTimeSpand = (expenses + cost) / KPI_TRESHOLD * avgNbOfViews * Double(nbOfMasters) 
    default:
      return
    }
    self.updater.toggle()
  }

  
  var body: some View {
      Form() {
          Section() {
            Text(kpi, format: .number)
              .multilineTextAlignment(.center)
              .foregroundColor(kpi.isNaN || kpi > KPI_TRESHOLD ? Color.red : Color.green)
          }  header: {
            HStack {
              Text("Целевой Показатель")
              Spacer()
              Text(buildVersion())
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.indigo)
                .onTapGesture {
                  showingBox = true
                }
                .alert(isPresented: $showingBox) {
                  Alert(
                      title: Text("Разработчик программы – Сергей Н. Калачёв"),
                      message: Text("\nРазработка iOS приложений и всего спектра информационных систем с web-интерфейсом от сайта визитки до ERP систем уровня предприятия в основном с помощью Symfony (PHP), Doctrine (MariaDB) и Javascript.\n\n@ksn135\n+7 985 766 6191\nserg@kalachev.ru")
                  )
                }
            }
          }
          Section(header: Text("Числитель")) {
            TextField(LocalizedStringKey("Стоимость компании"), value: $cost, formatter: rubNumberFormatter)
              .multilineTextAlignment(.trailing)
              .focused($focusedField, equals: .cost)
              .submitLabel(.next)
              .keyboardType(.numbersAndPunctuation)
              .foregroundColor(cost.isNaN || cost <= 0 ? Color.red : Color.black)
              .textFieldStyle(
                .floating(
                  showClearButton: false,
                  titleStyle: .init(text:  LocalizedStringKey("Стоимость компании"))
                  //                  errorStyle: .init(text: LocalizedStringKey("Укажите Стоимость компании"))
                )
              )
            TextField(LocalizedStringKey("Потрачено"), value: $expenses, formatter: rubNumberFormatter)
              .multilineTextAlignment(.trailing)
              .focused($focusedField, equals: .expenses)
              .submitLabel(.next)
              .keyboardType(.numbersAndPunctuation)
              .foregroundColor(expenses.isNaN || expenses < 0 ? Color.red : Color.black)
              .textFieldStyle(
                .floating(
                  showClearButton: false,
                  titleStyle: .init(text:  LocalizedStringKey("Потрачено"))
                )
              )
          }
          Section(header: Text("Знаменатель")) {
            TextField(LocalizedStringKey("Количество мастеров"), value: $nbOfMasters, format: .number)
              .multilineTextAlignment(.trailing)
              .focused($focusedField, equals: .nbOfMasters)
              .submitLabel(.next)
              .keyboardType(.numbersAndPunctuation)
              .foregroundColor(nbOfMasters <= 0 ? Color.red : Color.black)
              .textFieldStyle(
                .floating(
                  showClearButton: false,
                  titleStyle: .init(text:  LocalizedStringKey("Количество мастеров"))
                )
              )
            TextField(LocalizedStringKey("Среднее количество просмотров"), value: $avgNbOfViews, formatter: numNumberFormatter)
              .multilineTextAlignment(.trailing)
              .focused($focusedField, equals: .avgNbOfViews)
              .submitLabel(.next)
              .keyboardType(.numbersAndPunctuation)
              .foregroundColor(avgNbOfViews <= 0 ? Color.red : Color.black)
              .textFieldStyle(
                .floating(
                  showClearButton: false,
                  titleStyle: .init(text:  LocalizedStringKey("Среднее количество просмотров"))
                )
              )
            TextField(LocalizedStringKey("Средняя длительность просмотра"), value: $avgTimeSpand, formatter: numNumberFormatter)
              .multilineTextAlignment(.trailing)
              .focused($focusedField, equals: .avgTimeSpand)
              .submitLabel(.done)
              .keyboardType(.numbersAndPunctuation)
              .foregroundColor(avgTimeSpand <= 0 ? Color.red : Color.black)
              .textFieldStyle(
                .floating(
                  showClearButton: false,
                  titleStyle: .init(text: LocalizedStringKey("Средняя длительность просмотра"))
                )
              )
          }
          HStack {
            Spacer()
//            Text("Подбор")
//            .buttonStyle(.borderedProminent)
//            .buttonBorderShape(.capsule)
//            .controlSize(.large)
            HStack {
                Text("Оптимизация параметра")
                Image(systemName: "arrow.down.left.video")
            }
            .font(.subheadline)
            .padding()
            .frame(height: 20)
            .background(Color(red: 0 / 255, green: 94 / 255, blue: 149 / 255))
            .foregroundColor(.white)
            .padding(5)
            .border(Color(red: 0 / 255, green: 94 / 255, blue: 149 / 255), width: 5)
            .cornerRadius(15)
            .contextMenu{
              Button() {
                recalculate(recalculateField: .expenses)
              } label: {
                Text("Потрачено")
              }
              Button() {
                recalculate(recalculateField: .nbOfMasters)
              } label: {
                Text("Количеств мастеров")
              }
              Button() {
                recalculate(recalculateField: .avgNbOfViews)
              } label: {
                Text("Среднее количество просмотров")
              }
              Button() {
                recalculate(recalculateField: .avgTimeSpand)
              } label: {
                Text("Средняя длительность просмотра")
              }
            }
            //          .alignmentGuide(.center)
            Spacer()
          }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .onSubmit {
            switch focusedField {
            case .cost:
                focusedField = .expenses
            case .expenses:
//                focusedField = .masterCost
//            case .masterCost:
                focusedField = .nbOfMasters
            case .nbOfMasters:
                focusedField = .avgNbOfViews
            case .avgNbOfViews:
                focusedField = .avgTimeSpand
//            case .avgTimeSpand:
            default:
                focusedField = nil
            }
        }
//        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//      }
//      Spacer()
    }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
