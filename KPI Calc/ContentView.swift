//
//  ContentView.swift
//  KPI Calc
//
//  Created by Serg Kalachev on 01.12.2022.
//

import SwiftUI
import Combine

struct ContentView: View {
  enum Field {
    case cost
    case expenses
    case nbOfMasters
    case avgNbOfViews
    case avgTimeSpand
  }
    
  @State private var cost = 1100500.0
  @State private var expenses = 0.0
  @State private var nbOfMasters : Int = 10
  @State private var avgNbOfViews = 10000.0
  @State private var avgTimeSpand = 22.5
  
  @FocusState private var focusedField: Field?

  @State private var showingBox = false

  private let KPI_TRESHOLD: Double = 0.78000001

  let numNumberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.locale =  Locale(identifier: "ru_RU")
    return numberFormatter
  }()

  let ceilNumberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.minimumFractionDigits = 0
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
    let divider = Double(nbOfMasters) * avgNbOfViews * avgTimeSpand
    if (divider.isNaN || divider.isZero) {
      return 0;
    }
    return (cost + expenses) / divider
  }

  func recalculate(recalculateField: Field) -> Void {
    switch recalculateField {
    case .expenses:
      self.expenses = KPI_TRESHOLD * Double(nbOfMasters) * avgNbOfViews * avgTimeSpand - cost
    case .nbOfMasters:
      self.nbOfMasters = 1 + Int(ceil((expenses + cost) / (KPI_TRESHOLD * avgNbOfViews * avgTimeSpand)))
    case .avgNbOfViews:
      self.avgNbOfViews = (expenses + cost) / (KPI_TRESHOLD * Double(nbOfMasters) * avgTimeSpand)
    case .avgTimeSpand:
      self.avgTimeSpand = (expenses + cost) / (KPI_TRESHOLD * Double(nbOfMasters) * avgNbOfViews)
    default:
      return
    }
  }
  
  var body: some View {
      Form {
          Section() {
            HStack {
              Text("KPI:")
              Text(kpi, format: .number)
                .multilineTextAlignment(.center)
                .foregroundColor(kpi.isNaN || kpi > KPI_TRESHOLD ? Color.red : Color.green)
                .textSelection(.enabled)
              Spacer()
              HStack {
                  Text("Подбор")
                  Image(systemName: "chevron.up.chevron.down")
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
            }
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
            HStack {
              Text("Стоимость компании")
              TextField(LocalizedStringKey("рубли"), value: $cost, formatter: numNumberFormatter)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .cost)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
                .submitLabel(.done)
                .keyboardType(.numbersAndPunctuation)
                .foregroundColor(cost.isNaN || cost <= 0 ? Color.red : Color.black)
            }
            HStack {
              Text("Потрачено")
              TextField(LocalizedStringKey("рубли"), value: $expenses, formatter: numNumberFormatter)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .expenses)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
                .submitLabel(.done)
                .keyboardType(.numbersAndPunctuation)
                .foregroundColor(expenses.isNaN || expenses < 0 ? Color.red : Color.black)
            }
          }
          Section(header: Text("Знаменатель")) {
            HStack {
              Text("Количество мастеров")
              Stepper("", onIncrement: {
                   self.nbOfMasters += 1
               }, onDecrement: {
                 if (self.nbOfMasters > 1) {
                   self.nbOfMasters -= 1
                 }
               })
              TextField(LocalizedStringKey("штук"), value: $nbOfMasters, formatter: ceilNumberFormatter)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .nbOfMasters)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
                .submitLabel(.done)
                .keyboardType(.numbersAndPunctuation)
                .foregroundColor(nbOfMasters <= 0 ? Color.red : Color.black)
            }
            HStack {
              Text("Среднее количество просмотров")
              TextField(LocalizedStringKey("штук"), value: $avgNbOfViews, formatter: numNumberFormatter)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .avgNbOfViews)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
                .submitLabel(.done)
                .keyboardType(.numbersAndPunctuation)
                .foregroundColor(avgNbOfViews <= 0 ? Color.red : Color.black)
            }
            HStack {
              Text("Средняя длительность просмотра")
              TextField(LocalizedStringKey("минут"), value: $avgTimeSpand, formatter: numNumberFormatter)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .avgTimeSpand)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
                .submitLabel(.done)
                .keyboardType(.numbersAndPunctuation)
                .foregroundColor(avgTimeSpand <= 0 ? Color.red : Color.black)
            }
          }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
            if let textField = obj.object as? UITextField {
                textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            }
        }
        .onSubmit {
                focusedField = nil
        }
      Spacer()
    }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
