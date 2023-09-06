import 'package:closer/MyWidget.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/constant/app_size.dart';
import 'package:closer/constant/font_size.dart';
import 'package:closer/localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderRecipt extends StatefulWidget {
  const OrderRecipt({Key? key}) : super(key: key);

  @override
  State<OrderRecipt> createState() => _OrderReciptState();
}

class _OrderReciptState extends State<OrderRecipt> {

  String _num = '57898';
  String _numDelivery = '57898';
  String _date = 'July 12 , 2021';
  String _addressTitle = 'ttt';
  String _addressPhone = '999';
  String _addressNote = '999';
  List _orderItems = [1,2];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWidget.appBar(title: AppLocalizations.of(context)!.translate('INVOICE')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: AppWidth.w2, color: AppColors.Whitegray.withOpacity(0.4))
                ),
                margin: EdgeInsets.symmetric(horizontal: AppPadding.p20, vertical: AppPadding.p10),
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p10, vertical: AppPadding.p10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate('INVOICE')),
                        MyWidget(context).textBlack20(_date, scale: 0.8),
                      ],
                    ),
                    MyWidget(context).textHead10(AppLocalizations.of(context)!.translate('INVOICE')  + '#  $_num', color: AppColors.red, scale: 0.4),
                    MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate('Delivery No') + ': $_numDelivery', scale: 0.8),
                    Divider(color: AppColors.black, thickness: 1,),
                    MyWidget(context).textHead10(AppLocalizations.of(context)!.translate('Billing Address'), color: AppColors.black, scale: 0.4),
                    MyWidget(context).textBlack20(_addressTitle, scale: 0.7, color: AppColors.gray),
                    MyWidget(context).textBlack20(_addressPhone, scale: 0.7, color: AppColors.gray),
                    MyWidget(context).textBlack20(_addressNote, scale: 0.7, color: AppColors.gray),
                    Divider(color: AppColors.gray, thickness: 1,),
                    MyWidget(context).textHead10(AppLocalizations.of(context)!.translate('Shipping Address'), color: AppColors.black, scale: 0.4),
                    MyWidget(context).textBlack20(_addressTitle, scale: 0.7, color: AppColors.gray),
                    MyWidget(context).textBlack20(_addressPhone, scale: 0.7, color: AppColors.gray),
                    MyWidget(context).textBlack20(_addressNote, scale: 0.7, color: AppColors.gray),
                    Divider(color: AppColors.gray, thickness: 1,),
                    _tableRow(color: AppColors.black, scale: 0.4,
                        text1: AppLocalizations.of(context)!.translate('Item Description'),
                            text2: AppLocalizations.of(context)!.translate('Price'),
                        text3: AppLocalizations.of(context)!.translate('QTY'),
                        text4: AppLocalizations.of(context)!.translate('Total')
                    ),
                    Divider(color: AppColors.black, thickness: 1,),
                    Column(
                      children: _orderItems.map((e) =>
                          _tableRow1(color: AppColors.gray, scale: 0.35,
                              text1: AppLocalizations.of(context)!.translate('Item Description'),
                              text2: AppLocalizations.of(context)!.translate('Price'),
                              text3: AppLocalizations.of(context)!.translate('QTY'),
                              text4: AppLocalizations.of(context)!.translate('Total')
                          ),).toList(),
                    ),
                    Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: MyWidget(context).textHead10('text1', color: AppColors.black, scale: 0.4),
                      ),
                      Expanded(
                        flex: 2,
                        child: MyWidget(context).textHead10('text1', color: AppColors.gray, scale: 0.4),
                      ),
                      Expanded(
                        flex: 2,
                        child: MyWidget(context).textHead10('text1', color: AppColors.gray, scale: 0.4),
                      ),
                    ],
                  ),
                    Divider(color: AppColors.black, thickness: 1,),
                    MyWidget(context).textHead10(AppLocalizations.of(context)!.translate('Billing Address'), color: AppColors.black, scale: 0.4),
                    MyWidget(context).textBlack20(_addressTitle, scale: 0.7, color: AppColors.gray),
                  ],
                ),
              ),
            ),
          ),
          MyWidget(context).raisedButton(AppLocalizations.of(context)!.translate('Download Receipt'), ()=> _download(), AppWidth.w90, false),
          SizedBox(height: AppPadding.p20,)
        ],
      ),
    );
  }
  _tableRow({required color, required scale, required text1, required text2, required text3, required text4}){
    return  Row(
      children: [
        Expanded(
          flex: 5,
          child: MyWidget(context).textHead10(text1, color: color, scale: scale),
        ),
        Expanded(
          flex: 2,
          child: MyWidget(context).textHead10(text2, color: color, scale: scale, textAlign: TextAlign.center),
        ),
        Expanded(
          flex: 1,
          child: MyWidget(context).textHead10(text3, color: color, scale: scale, textAlign: TextAlign.center),
        ),
        Expanded(
          flex: 2,
          child: MyWidget(context).textHead10(text4, color: color, scale: scale, textAlign: TextAlign.center),
        )
      ],
    );

  }

  Widget _tableRow1({required color, required scale, required text1, required text2, required text3, required text4}){
    return  Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: MyWidget(context).textHead10(text1, color: color, scale: scale),
            ),
            Container(color: AppColors.black, height: FontSize.s16*2, width: 1,),
            Expanded(
              flex: 2,
              child: MyWidget(context).textHead10(text2, color: color, scale: scale, textAlign: TextAlign.center),
            ),
            Container(color: AppColors.black, height: FontSize.s16*2, width: 1,),
            Expanded(
              flex: 1,
              child: MyWidget(context).textHead10(text3, color: color, scale: scale, textAlign: TextAlign.center),
            ),
            Container(color: AppColors.black, height: FontSize.s16*2, width: 1,),
            Expanded(
              flex: 2,
              child: MyWidget(context).textHead10(text4, color: color, scale: scale, textAlign: TextAlign.center),
            )
          ],
        ),
        Divider(height: 1, color: AppColors.black,)
      ],
    );

  }

  _download() {}

}
