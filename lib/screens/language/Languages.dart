import 'package:closer/MyWidget.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/constant/app_size.dart';
import 'package:closer/constant/font_size.dart';
import 'package:closer/localizations.dart';
import 'package:flutter/material.dart';
class Languages extends StatefulWidget {
  const Languages({Key? key}) : super(key: key);

  @override
  State<Languages> createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  int _selectedLang = 0, _selectedCountry = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body:Padding(
        padding: EdgeInsets.all(AppPadding.p20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppHeight.h10),
                child: Center(
                  child: MyWidget(context).textHead10(AppLocalizations.of(context)!.translate('Language')),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppHeight.h2),
                child: MyWidget(context).textTitle15(AppLocalizations.of(context)!.translate('Select your country'), color: AppColors.white),
              ),
              _dropDownContry(),
              SizedBox(height: AppHeight.h2,),
              Padding(
                padding: EdgeInsets.all(AppHeight.h2),
                child: MyWidget(context).textTitle15(AppLocalizations.of(context)!.translate('Select your Language'), color: AppColors.white),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white),
                  borderRadius: BorderRadius.all(Radius.circular(AppWidth.w4)),
                ),
                padding: EdgeInsets.all(AppWidth.w4),
                child: Column(
                  children: [
                    _laguageSelect(headText: 'English', titleText: AppLocalizations.of(context)!.translate('English'), select: 0),
                    Divider(color: AppColors.white,),
                    _laguageSelect(headText: 'العربية', titleText: AppLocalizations.of(context)!.translate('Arabic'), select: 1),
                    Divider(color: AppColors.white,),
                    _laguageSelect(headText: 'Frânsk', titleText: AppLocalizations.of(context)!.translate('French'), select: 2),
                  ],
                ),
              ),
              SizedBox(height: AppHeight.h4,),
              MyWidget(context).raisedButton(AppLocalizations.of(context)!.translate('Save'), ()=>_save(), AppWidth.w80, false)
            ],
          ),
        ),
      ),
    );
  }
  List<String> _countryList = ['sudi', 'qatar', 'uae'];

  _dropDownContry() {
    return  Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 20,),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white),
        borderRadius: BorderRadius.all(Radius.circular(AppWidth.w4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: AppColors.mainColor1,
          // Initial Value
          value: _countryList[_selectedCountry],
          // Down Arrow Icon
          style: TextStyle(color: AppColors.white, fontSize: FontSize.s20),
          icon: const Icon(Icons.arrow_forward_ios, color: AppColors.white,),
          // Array list of items
          items: _countryList.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items,),
            );
          }).toList(),
          // After selecting the desired option,it will
          // change button value to selected value
          onChanged: (String? newValue) {
            setState(() {
              if(newValue!=null) _selectedCountry = _countryList.indexOf(newValue);
            });
          },
        ),
      ),
    );
  }

  _laguageSelect({required headText, required titleText, required select}){
    var isSelected = select==_selectedLang;
    return GestureDetector(
      onTap: ()=> setState(() {
        _selectedLang = select;
      }),
      child: Padding(
        padding: EdgeInsets.all(AppWidth.w2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyWidget(context).textHead10(headText, scale: 0.5),
                MyWidget(context).textTitle15(titleText, color: AppColors.white),
              ],
            ),
            Container(
              width: AppWidth.w8,
              height: AppWidth.w8,
              decoration: BoxDecoration(
                color: isSelected? AppColors.mainColor1:AppColors.purple1,
                borderRadius: BorderRadius.all(Radius.circular(AppWidth.w2)),
                //border: Border.all(color: AppColors.blackGray),
              ),
              child: isSelected ? Icon(Icons.check, color: AppColors.mainColor,):SizedBox(),
            )
          ],
        ),
      ),
    );
  }

  _save() {

  }
}
