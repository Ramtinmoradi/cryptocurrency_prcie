import 'package:crypto_price/data/constants/constants.dart';
import 'package:crypto_price/data/model/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CoinListScreen extends StatefulWidget {
  CoinListScreen({super.key, this.cryptoList});

  List<Crypto>? cryptoList;

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  List<Crypto>? cryptoList;
  bool isSearchLoadingVisible = false;

  @override
  void initState() {
    super.initState();
    cryptoList = widget.cryptoList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'قیمت کریپتو',
          style: TextStyle(
            fontFamily: 'mh',
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: blackColor,
      ),
      backgroundColor: blackColor,
      body: SafeArea(
        child: _getbody(),
      ),
    );
  }

  Widget _getbody() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                onChanged: (value) {
                  _filterList(value);
                },
                decoration: InputDecoration(
                  hintText: 'اسم رمز ارز را سرچ کنید',
                  hintStyle: TextStyle(
                    fontFamily: 'mh',
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      width: 0.0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  fillColor: greenColor,
                ),
              ),
            ),
          ),
          Visibility(
            visible: isSearchLoadingVisible,
            child: Text(
              'در حال آپدیت لیست و قیمت رمز ارز ها ...',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: greenColor,
                fontFamily: 'mh',
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              edgeOffset: 20.0,
              color: blackColor,
              backgroundColor: greenColor,
              onRefresh: () async {
                List<Crypto> freshData = await _getData();
                setState(() {
                  cryptoList = freshData;
                });
              },
              child: ListView.builder(
                itemCount: cryptoList!.length,
                itemBuilder: (context, index) {
                  return _getListTile(cryptoList![index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getListTile(Crypto crypto) {
    return ListTile(
      title: Text(
        crypto.symbol,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        crypto.name,
        style: TextStyle(
          color: greyColor,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: SizedBox(
        width: 40.0,
        child: Center(
          child: Text(
            crypto.rank.toString(),
            style: TextStyle(
              fontSize: 20.0,
              color: greyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      trailing: SizedBox(
        width: 150.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.priceUsd.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: greyColor,
                  ),
                ),
                Text(
                  '${crypto.changePercent24hr.toStringAsFixed(2)} %',
                  style: TextStyle(
                    color: _getPriceChangeColors(
                      crypto.changePercent24hr,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.0),
            SizedBox(
              width: 30.0,
              child: Center(
                child: _getIconChangePercent(
                  crypto.changePercent24hr,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriceChangeColors(double percentChange) {
    if (percentChange <= 0) {
      return redColor;
    } else {
      return greenColor;
    }
  }

  Widget _getIconChangePercent(double percentChange) {
    if (percentChange <= 0) {
      return Icon(
        Icons.trending_down,
        size: 30.0,
        color: redColor,
      );
    } else {
      return Icon(
        Icons.trending_up,
        size: 30.0,
        color: greenColor,
      );
    }
  }

  Future<List<Crypto>> _getData() async {
    var response = await Dio().get('https://api.coincap.io/v2/assets');
    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList();
    return cryptoList;
  }

  Future<void> _filterList(String enteredKeyword) async {
    List<Crypto> cryptoResultList = [];
    if (enteredKeyword.isEmpty) {
      setState(() {
        isSearchLoadingVisible = true;
      });
      var result = await _getData();
      setState(() {
        cryptoList = result;
        isSearchLoadingVisible = false;
      });
      return;
    }
    cryptoResultList = cryptoList!.where((element) {
      return element.name.toLowerCase().contains(enteredKeyword.toLowerCase());
    }).toList();

    setState(() {
      cryptoList = cryptoResultList;
    });
  }
}
