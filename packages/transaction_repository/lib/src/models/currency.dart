// ignore_for_file: deprecated_member_use
import 'package:xml/xml.dart' as xml;

class CurrencyModel {
  String kod;
  String currencyCode;
  int unit;
  String name;
  String currencyName;
  double forexBuying;
  double forexSelling;
  double? banknoteBuying;
  double? banknoteSelling;
  double? crossRateUSD;
  double? crossRateOther;
  int orderNo;

  CurrencyModel({
    required this.kod,
    required this.currencyCode,
    required this.unit,
    required this.name,
    required this.currencyName,
    required this.forexBuying,
    required this.forexSelling,
    this.banknoteBuying,
    this.banknoteSelling,
    this.crossRateUSD,
    this.crossRateOther,
    this.orderNo = 99,
  });

  factory CurrencyModel.fromXml(xml.XmlElement element) {
    return CurrencyModel(
      kod: element.getAttribute('Kod') ?? '',
      currencyCode: element.getAttribute('CurrencyCode') ?? '',
      unit: int.tryParse(element.findElements('Unit').single.text) ?? 0,
      name: element.findElements('Isim').single.text,
      currencyName: element.findElements('CurrencyName').single.text,
      forexBuying:
          double.tryParse(element.findElements('ForexBuying').single.text) ??
              0.0,
      forexSelling:
          double.tryParse(element.findElements('ForexSelling').single.text) ??
              0.0,
      banknoteBuying: element.findElements('BanknoteBuying').isNotEmpty
          ? double.tryParse(element.findElements('BanknoteBuying').single.text)
          : null,
      banknoteSelling: element.findElements('BanknoteSelling').isNotEmpty
          ? double.tryParse(element.findElements('BanknoteSelling').single.text)
          : null,
      crossRateUSD: element.findElements('CrossRateUSD').isNotEmpty &&
              element.findElements('CrossRateUSD').single.text.isNotEmpty
          ? double.tryParse(element.findElements('CrossRateUSD').single.text)
          : null,
      crossRateOther: element.findElements('CrossRateOther').isNotEmpty &&
              element.findElements('CrossRateOther').single.text.isNotEmpty
          ? double.tryParse(element.findElements('CrossRateOther').single.text)
          : null,
    );
  }

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      kod: map['kod'] as String,
      currencyCode: map['currencyCode'] as String,
      unit: map['unit'] as int,
      name: map['name'] as String,
      currencyName: map['currencyName'] as String,
      forexBuying: map['forexBuying'] as double,
      forexSelling: map['forexSelling'] as double,
      banknoteBuying: map['banknoteBuying'] as double?,
      banknoteSelling: map['banknoteSelling'] as double?,
      crossRateUSD: map['crossRateUSD'] as double?,
      crossRateOther: map['crossRateOther'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currencyCode': currencyCode,
    };
  }

  factory CurrencyModel.empty() {
    return CurrencyModel(
      kod: '',
      currencyCode: '',
      unit: 0,
      name: '',
      currencyName: '',
      forexBuying: 0.0,
      forexSelling: 0.0,
    );
  }
}

Future<CurrencyRates> parseCurrencyFromResponse(String xmlString) async {
  final xmlDocument = xml.XmlDocument.parse(xmlString);
  var currencyRates = CurrencyRates.fromXml(xmlDocument);
  currencyRates.currencies.add(CurrencyModel(
    kod: 'TR',
    currencyCode: 'TR',
    unit: 1,
    name: 'TÜRK LİRASI',
    currencyName: 'TURKİSH LİRA',
    forexBuying: 1.0,
    forexSelling: 1.0,
  ));
  currencyRates.currencies
      .removeWhere((element) => element.currencyCode == 'XDR');
  for (var currency in currencyRates.currencies) {
    switch (currency.currencyCode) {
      case 'DKK':
        currency.name = 'DANIMARKA KRONU';
        break;
      case 'GBP':
        currency.name = 'İNGİLİZ STERLİNİ';
        break;
      case 'CHF':
        currency.name = 'İSVİÇRE FRANGI';
        break;
      case 'SEK':
        currency.name = 'İSVEÇ KRONU';
        break;
      case 'KWD':
        currency.name = 'KUVEYT DİNARI';
        break;
      case 'NOK':
        currency.name = 'NORVEÇ KRONU';
        break;
      case 'SAR':
        currency.name = 'SUUDİ ARABİSTAN RİYALİ';
        break;
      case 'JPY':
        currency.name = 'JAPON YENİ';
        break;
      case 'RON':
        currency.name = 'RUMEN LEYİ';
        break;
      case 'RUB':
        currency.name = 'RUS RUBLESİ';
        break;
      case 'IRR':
        currency.name = 'İRAN RİYALİ';
        break;
      case 'CNY':
        currency.name = 'ÇİN YUANI';
        break;
      case 'PKR':
        currency.name = 'PAKİSTAN RUPİSİ';
        break;
      case 'QAR':
        currency.name = 'KATAR RİYALİ';
        break;
      case 'KRW':
        currency.name = 'GÜNEY KORE WONU';
        break;
      case 'AZN':
        currency.name = 'AZERBAYCAN YENİ MANATI';
        break;
      case 'AED':
        currency.name = 'BİRLEŞİK ARAP EMİRLİKLERİ DİRHEMİ';
        break;
      case 'TR':
        currency.orderNo = 0;
        break;
      case 'EUR':
        currency.orderNo = 1;
        break;
      case 'USD':
        currency.orderNo = 2;
        break;
      case 'AUD':
        currency.orderNo = 3;
        break;
      case 'CAD':
        currency.orderNo = 4;
        break;
      default:
        break;
    }
  }
  return currencyRates;
}

class CurrencyRates {
  final String date;
  final List<CurrencyModel> currencies;

  CurrencyRates({
    required this.date,
    required this.currencies,
  });

  factory CurrencyRates.fromXml(xml.XmlDocument xmlDocument) {
    final rootElement = xmlDocument.getElement('Tarih_Date')!;
    final currencies =
        rootElement.findElements('Currency').map((currencyElement) {
      return CurrencyModel.fromXml(currencyElement);
    }).toList();
    return CurrencyRates(
      date: rootElement.getAttribute('Tarih')!,
      currencies: currencies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'currencies': currencies.map((currency) => currency.toMap()).toList(),
    };
  }
}

String getCurrencySymbolFromCurrencyCode(String code) {
  switch (code) {
    case 'USD':
    case 'AUD':
    case 'CAD':
      return '\$';
    case 'DKK':
    case 'SEK':
    case 'NOK':
      return 'kr';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'CHF':
      return 'CHF';
    case 'KWD':
      return 'د.ك';
    case 'SAR':
      return 'ر.س';
    case 'JPY':
    case 'CNY':
      return '¥';
    case 'BGN':
      return 'лв';
    case 'RON':
      return 'lei';
    case 'RUB':
      return '₽';
    case 'IRR':
      return '﷼';
    case 'PKR':
      return '₨';
    case 'QAR':
      return 'ر.ق';
    case 'KRW':
      return '₩';
    case 'AZN':
      return '₼';
    case 'AED':
      return 'د.إ';
    case 'TR':
      return '₺';
    default:
      return '';
  }
}
