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
  
  @State private var cost         : Double = 0.0
  @State private var expenses     : Double = 0.0
  @State private var nbOfMasters  : Int    = 0
  @State private var avgNbOfViews : Double = 0.0
  @State private var avgTimeSpand : Double = 0.0
  
  @FocusState private var focusedField: Field?
  
  @State private var showingBox = false
  
  private let KPI_TRESHOLD: Double = 0.78000001
  
  let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.locale =  Locale(identifier: "ru_RU")
    numberFormatter.generatesDecimalNumbers = true
    numberFormatter.zeroSymbol = ""
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
          Text("Стоимость")
          TextField("рубли", value: $cost, formatter: numberFormatter)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .cost)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(cost.isNaN || cost <= 0 ? Color.red : Color.primary)
        }
        HStack {
          Text("Потрачено")
          TextField("рубли", value: $expenses, formatter: numberFormatter)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .expenses)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(expenses.isNaN || expenses < 0 ? Color.red : Color.primary)
        }
      }
      Section(header: Text("Знаменатель")) {
        HStack {
          Text("Количество мастеров")
          Stepper("", onIncrement: {
            focusedField = nil
            self.nbOfMasters += 1
          }, onDecrement: {
            if (self.nbOfMasters > 1) {
              focusedField = nil
              self.nbOfMasters -= 1
            }
          })
          TextField("кол-во", value: $nbOfMasters, format: .number)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .nbOfMasters)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(nbOfMasters <= 0 ? Color.red : Color.primary)
        }
        HStack {
          Text("Среднее количество")
          TextField("просмотры", value: $avgNbOfViews, formatter: numberFormatter)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .avgNbOfViews)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(avgNbOfViews <= 0 ? Color.red : Color.primary)
        }
        HStack {
          Text("Средняя длительность")
          TextField("минут", value: $avgTimeSpand, formatter: numberFormatter)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .avgTimeSpand)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(avgTimeSpand <= 0 ? Color.red : Color.primary)
        }
      }
    }
    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
