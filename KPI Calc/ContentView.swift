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
    case duration
    case avgNbOfViews
    case avgTimeSpand
  }
  
  @State private var cost         : Double = 6_000_000.0
  @State private var expenses     : Double = 6_200_000.0
  @State private var nbOfMasters  : Int    = 22
  @State private var duration     : Int    = 45
  @State private var avgNbOfViews : Double = 500_000.0
  @State private var avgTimeSpand : Double = 50.0

  
  @FocusState private var focusedField: Field?
  
  @State private var showingBox = false
  
  private let KPI_TRESHOLD: Double = 0.78000001

  @State private var showingUndo = false

  @State private var undocost         : Double = 0.0
  @State private var undoexpenses     : Double = 0.0
  @State private var undonbOfMasters  : Int    = 0
  @State private var undoduration     : Int    = 0
  @State private var undoavgNbOfViews : Double = 0.0
  @State private var undoavgTimeSpand : Double = 0.0
  
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
  
  var numerator:  Double {
    return  Double(nbOfMasters) * (cost + expenses);
  }
  
  var denominator: Double {
    return Double(nbOfMasters) * (avgTimeSpand / 100) * avgNbOfViews * Double(duration)
  }
  
  var kpi: Double {
    let divider = denominator
    if (divider.isNaN || divider.isZero) {
      return 0;
    }
    return numerator / divider
  }

  func undo() -> Void {
    self.cost = undocost
    self.expenses = undoexpenses
    self.duration = undoduration
    self.nbOfMasters = undonbOfMasters
    self.avgNbOfViews = undoavgNbOfViews
    self.avgTimeSpand = undoavgTimeSpand
    self.showingUndo = false
  }
  
  func recalculate(recalculateField: Field) -> Void {
    if (!self.showingUndo) {
      self.undocost = cost
      self.undoexpenses = expenses
      self.undonbOfMasters = nbOfMasters
      self.undoduration = duration
      self.undoavgNbOfViews = avgNbOfViews
      self.undoavgTimeSpand = avgTimeSpand
      self.showingUndo = true
    }
    switch recalculateField {
    case .cost:
      self.cost = KPI_TRESHOLD * Double(duration) * avgNbOfViews * (avgTimeSpand / 100) - expenses
    case .expenses:
      self.expenses = KPI_TRESHOLD * Double(duration) * avgNbOfViews * (avgTimeSpand / 100) - cost
    case .duration:
      self.duration = 1 + Int(ceil((expenses + cost) / (KPI_TRESHOLD * avgNbOfViews * (avgTimeSpand / 100))))
    case .avgNbOfViews:
      self.avgNbOfViews = ((expenses + cost) / (KPI_TRESHOLD *  (avgTimeSpand / 100) * Double(duration))).rounded(.up)
    case .avgTimeSpand:
      self.avgTimeSpand = 100 * (expenses + cost) / (KPI_TRESHOLD * avgNbOfViews * Double(duration))
    default:
      return
    }
  }
  
  var body: some View {
    Form {
      Section() {
        HStack {
          Text("Количество мастеров")
          TextField("кол-во", value: $nbOfMasters, format: .number)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .nbOfMasters)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(nbOfMasters <= 0 ? Color.red : Color.primary)
        }
        HStack {
          Text("Стоимость за 1 мастер")
          TextField("рубли", value: $cost, formatter: numberFormatter)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .cost)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(cost.isNaN || cost <= 0 ? Color.red : Color.primary)
        }
        HStack {
          Text("Доп к с/с (продажа МКП)")
          TextField("рубли", value: $expenses, formatter: numberFormatter)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .expenses)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(expenses.isNaN || expenses < 0 ? Color.red : Color.primary)
        }
        HStack {
          Text("Хронометраж")
          TextField("минут", value: $duration, format: .number)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .duration)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(duration <= 0 ? Color.red : Color.primary)
          Text("м")
        }
        HStack {
          Text("Средняя длительность просмотра")
          TextField("минут", value: $avgTimeSpand, formatter: numberFormatter)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .avgTimeSpand)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(avgTimeSpand <= 0 ? Color.red : Color.primary)
          Text("%")
        }
        HStack {
          Text("Среднее количество просмотров")
          TextField("проценты", value: $avgNbOfViews, formatter: numberFormatter)
            .multilineTextAlignment(.trailing)
            .focused($focusedField, equals: .avgNbOfViews)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(avgNbOfViews <= 0 ? Color.red : Color.primary)
        }
      }  header: {
        HStack {
          Text("Параметры")
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
      Section(header: Text("Рзультат")) {
        HStack {
          Text("Числитель")
            .fontWeight(.bold)
            .underline()
          Spacer()
          Text(numerator.rounded(.up), format: .number)
            .multilineTextAlignment(.trailing)
            .textSelection(.enabled)
        }
        HStack {
          Text("Знаменатель")
            .fontWeight(.bold)
            .underline()
          Spacer()
          Text(denominator.rounded(.up), format: .number)
            .multilineTextAlignment(.trailing)
            .textSelection(.enabled)
        }
      }
      Section() {
        HStack {
          Text("KPI:").fontWeight(.bold)
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
              recalculate(recalculateField: .cost)
            } label: {
              Text("Стоимость за 1 мастер")
            }
            Button() {
              recalculate(recalculateField: .expenses)
            } label: {
              Text("Доп к с/с (продажа МКП)")
            }
            Button() {
              recalculate(recalculateField: .duration)
            } label: {
              Text("Хронометраж")
            }
            Button() {
              recalculate(recalculateField: .avgTimeSpand)
            } label: {
              Text("Средняя длительность просмотра")
            }
            Button() {
              recalculate(recalculateField: .avgNbOfViews)
            } label: {
              Text("Среднее количество просмотров")
            }
          }
        }
      }  header: {
        HStack {
          Text("Целевой Показатель")
          Spacer()
          if showingUndo {
            Button(action: {
              undo()
            }) {
              Image(systemName:"arrow.uturn.backward")
              Text("Вернуть")
            }
          }
        }
      }
      .padding(5)
      .border(Color.black, width: 1)

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
