import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


void main() => runApp(MyApp());


bool title_order = true;

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final title = 'WebSocket Demo';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        channel: IOWebSocketChannel.connect('wss://futures.kraken.com/ws/v1'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;

  MyHomePage({Key key, @required this.title, @required this.channel})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();

  int change_status = 0;
  var first_book;
  int depth_Ask;
  int depth_Bid;

  var data;
  var ask_Book;
  var bid_Book;
  int change_status_bid = 0;
  int change_status_ask = 0;


  List Ask_Book_total = List();
  List Bid_Book_total = List();
  List Ask_Book_price = List();
  List Bid_Book_price = List();

  List Ask_Book_total2 = List();
  List Bid_Book_total2 = List();
  List Ask_Book_price2 = List();
  List Bid_Book_price2 = List();


  @override
  Widget build(BuildContext context)

  {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xff060611),
      appBar: AppBar(

        backgroundColor: Colors.black,
        title: Text("Kraken Order Book"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 108,

              padding:
              const EdgeInsets.only(top: 15.0, left: 25.0, right: 25.0,bottom: 15),

              decoration: BoxDecoration(
                color: Color(0xff171721),
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(7.0) //         <--- border radius here
                ),
              ),
              child:Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.0,
                        offset: Offset(0, 2)
                    ),
                  ],
                ),
                height: 80.0,
                width: double.maxFinite,

                child:

                Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(12, 10, 0, 0),

                        child: Text(
                          "Quantity",
                          style: TextStyle(fontWeight: FontWeight.w200,fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ),

                    Padding(
                      padding:
                      const EdgeInsets.only(top: 0.0, left: 12.0, right: 12.0,bottom: 1),

                      child: TextField(

                        controller:  controller,
                        keyboardType: TextInputType.number,

                        decoration: InputDecoration.collapsed(
                          hintText:"0",


                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ),

            SizedBox(
              height: 10,
            ),

            StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {

                var parsed;


                if(change_status_ask == 1  && change_status_bid == 1){

                  parsed = json.decode(snapshot.data);


                  var ask_Blength = Ask_Book_price.length;
                  var bid_Blength = Bid_Book_price.length;


                  if(parsed["side"] == "sell"){


                    if(ask_Blength < 10){
                      var total;
                      var was_sum = 0;

                      for(int i = 0; i < ask_Blength; i++ ){


                        if(double.parse(parsed["price"].toString()) == double.parse(Ask_Book_price[i].toString())){

                          if(double.parse(parsed["qty"].toString()) > 0 && double.parse(Ask_Book_price[i].toString()) > 0){
                            total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString())) + (double.parse(Ask_Book_total[i].toString()))/(double.parse(Ask_Book_total[i].toString()));
                            Ask_Book_total.removeAt(i);
                            Ask_Book_price.removeAt(i);
                            Ask_Book_price.insert(i, parsed["price"].toString());
                            Ask_Book_total.insert(i, total.toStringAsFixed(3));
                            was_sum = 1;

                            i == ask_Blength;
                          }

                        }

                      }

                      if(was_sum == 0){

                        for(int i = 0; i < ask_Blength; i++ ){


                          if(i == 0){
                            if(double.parse(parsed["price"].toString()) < double.parse(Ask_Book_price[i].toString())){
                              Ask_Book_price.insert(i, parsed["price"].toString());
                              total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                              Ask_Book_total.insert(i, total.toStringAsFixed(3));
                              i == ask_Blength;
                            }
                          }
                          else if(double.parse(parsed["price"].toString()) < double.parse(Ask_Book_price[i].toString())  && double.parse(parsed["price"].toString()) > double.parse(Ask_Book_price[i-1].toString())){
                            Ask_Book_price.insert(i, parsed["price"].toString());
                            total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                            Ask_Book_total.insert(i, total.toStringAsFixed(3));
                            i == ask_Blength;
                          }

                        }
                      }
                    }
                    else{
                      var total;
                      var was_sum = 0;
                      for(int i = 0; i < ask_Blength; i++ ){
                        if(double.parse(parsed["price"].toString()) == double.parse(Ask_Book_price[i].toString())){
                          if(double.parse(parsed["qty"].toString()) > 0 && double.parse(Ask_Book_price[i].toString()) > 0){
                            total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString())) + (double.parse(Ask_Book_total[i].toString()))/(double.parse(Ask_Book_total[i].toString()));
                            Ask_Book_total.removeAt(i);
                            Ask_Book_price.removeAt(i);
                            Ask_Book_price.insert(i, parsed["price"].toString());
                            Ask_Book_total.insert(i, total.toStringAsFixed(3));
                            was_sum = 1;

                            i == ask_Blength;
                          }

                        }



                      }
                      if(was_sum == 0){

                        for(int i = 0; i < ask_Blength; i++ ){


                          if(i == 0){
                            if(double.parse(parsed["price"].toString()) < double.parse(Ask_Book_price[i].toString())){
                              Ask_Book_price.removeAt(ask_Blength-1);
                              Ask_Book_total.removeAt(ask_Blength-1);
                              Ask_Book_price.insert(i, parsed["price"].toString());
                              total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                              Ask_Book_total.insert(i, total.toStringAsFixed(3));
                              i == ask_Blength;
                            }
                          }
                          else if(double.parse(parsed["price"].toString()) < double.parse(Ask_Book_price[i].toString())  && double.parse(parsed["price"].toString()) > double.parse(Ask_Book_price[i-1].toString())){
                            Ask_Book_price.removeAt(ask_Blength-1);
                            Ask_Book_total.removeAt(ask_Blength-1);
                            Ask_Book_price.insert(i, parsed["price"].toString());
                            total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                            Ask_Book_total.insert(i, total.toStringAsFixed(3));
                            i == ask_Blength;
                          }
                        }
                      }
                    }
                  }
                  else if(parsed["side"] == "buy"){
/*
                    for(int i = 0 ; i > ask_Blength; i ++){
                      if(double.parse(parsed["price"].toString()) > double.parse(Ask_Book_price[i].toString())){
                        Ask_Book_total.removeAt(i);
                        Ask_Book_price.removeAt(i);
                      }
                    }

 */


                    if(bid_Blength < 10){
                      var total;
                      var was_sum = 0;

                      for(int i = 0; i < bid_Blength; i++ ){


                        if(double.parse(parsed["price"].toString()) == double.parse(Bid_Book_price[i].toString())){

                          if(double.parse(parsed["qty"].toString()) > 0 && double.parse(Bid_Book_price[i].toString()) > 0){
                            total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString())) + (double.parse(Bid_Book_total[i].toString()))/(double.parse(Bid_Book_total[i].toString()));
                            Bid_Book_total.removeAt(i);
                            Bid_Book_price.removeAt(i);
                            Bid_Book_price.insert(i, parsed["price"].toString());
                            Bid_Book_total.insert(i, total.toStringAsFixed(3));
                            was_sum = 1;
                            i == bid_Blength;
                          }

                        }
                      }

                      if(was_sum == 0){
                        for(int i = 0; i < bid_Blength; i++ ){

                          if(i == 0){
                            if(double.parse(parsed["price"].toString()) > double.parse(Bid_Book_price[i].toString())){
                              Bid_Book_price.insert(i, parsed["price"].toString());
                              total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                              Bid_Book_total.insert(i, total.toStringAsFixed(3));
                              i == bid_Blength;
                            }
                          }
                          else if(double.parse(parsed["price"].toString()) > double.parse(Bid_Book_price[i].toString()) && double.parse(parsed["price"].toString()) < double.parse(Bid_Book_price[i-1].toString())){
                            Bid_Book_price.insert(i, parsed["price"].toString());
                            total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                            Bid_Book_total.insert(i, total.toStringAsFixed(3));
                            i == bid_Blength;
                          }
                        }
                      }
                    }

                    else{

                      var total;
                      var was_sum = 0;

                      for(int i = 0; i < bid_Blength; i++ ){


                        if(double.parse(parsed["price"].toString()) == double.parse(Bid_Book_price[i].toString())){

                          if(double.parse(parsed["qty"].toString()) > 0 && double.parse(Bid_Book_price[i].toString()) > 0){
                            total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString())) + (double.parse(Bid_Book_total[i].toString()))/(double.parse(Bid_Book_total[i].toString()));
                            Bid_Book_total.removeAt(i);
                            Bid_Book_price.removeAt(i);
                            Bid_Book_price.insert(i, parsed["price"].toString());
                            Bid_Book_total.insert(i, total.toStringAsFixed(3));
                            was_sum = 1;

                            i == bid_Blength;
                          }

                        }
                      }

                      if(was_sum == 0){
                        for(int i = 0; i < bid_Blength; i++ ){
                          if(i == 0){
                            if(double.parse(parsed["price"].toString()) < double.parse(Bid_Book_price[i].toString())){
                              Bid_Book_price.removeAt(bid_Blength-1);
                              Bid_Book_total.removeAt(bid_Blength-1);
                              Bid_Book_price.insert(i, parsed["price"].toString());
                              total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                              Bid_Book_total.insert(i, total.toStringAsFixed(3));
                              i == bid_Blength;
                            }
                          }
                          else if(double.parse(parsed["price"].toString()) < double.parse(Bid_Book_price[i].toString()) && double.parse(parsed["price"].toString()) > double.parse(Bid_Book_price[i-1].toString())){
                            Bid_Book_price.removeAt(bid_Blength-1);
                            Bid_Book_total.removeAt(bid_Blength-1);
                            Bid_Book_price.insert(i, parsed["price"].toString());
                            total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                            Bid_Book_total.insert(i, total.toStringAsFixed(3));
                            i == bid_Blength;
                          }
                        }
                      }
                    }

                  }

                  depth_Ask = Ask_Book_price.length;
                  depth_Bid = Bid_Book_price.length;
                  Ask_Book_total2 = Ask_Book_total;
                  Ask_Book_price2 = Ask_Book_price;
                  Bid_Book_price2 = Bid_Book_price.reversed.toList();
                  Bid_Book_total2 = Bid_Book_total.reversed.toList();

                  return  Container(
                    height: 360,
                    decoration: BoxDecoration(
                      color: Color(0xff171721),
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(
                          Radius.circular(7.0) //         <--- border radius here
                      ),
                    ),




                            child: Row(
                              children: <Widget>[

                                Expanded(
                                  child: Container(
                                    padding:
                                    const EdgeInsets.only(top: 10.0, bottom: 10),

                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0) //         <--- border radius here
                                      ),
                                    ),
                                    child:    ListView.builder(

                                      itemBuilder: (context, index) {



                                        if(index > 0){
                                          title_order = false;
                                        }
                                        else{
                                          title_order = true;
                                        }

                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: (){
                                                controller.text = Bid_Book_price2[index].toString();
                                              },
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    padding:
                                                    const EdgeInsets.only(top: 1.0, left: 8.0, right: 16.0),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[

                                                        Visibility (
                                                          visible: title_order,

                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0,bottom: 5),
                                                            child:   Text(
                                                              "Total",
                                                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 16),

                                                            ),
                                                          ),


                                                          replacement: SizedBox(height: 1,),
                                                        ),


                                                        Container(
                                                          padding:
                                                          const EdgeInsets.only(top: 5.0, left: 16.0, right: 0.0,bottom: 5),
                                                          child:  Text(
                                                            Bid_Book_total2[index],
                                                            style: TextStyle(color: Colors.white, fontSize: 13),
                                                          ),
                                                        ),



                                                      ],
                                                    ),
                                                  ),


                                                  Container(
                                                    padding:
                                                    const EdgeInsets.only(top: 1.0, left: 15.0, right: 4.0),
                                                    child:
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        Visibility (
                                                          visible: title_order,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0,bottom: 5),
                                                            child:   Text(
                                                              "Price",
                                                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 16),

                                                            ),
                                                          ),

                                                          replacement: SizedBox(height: 1,),
                                                        ),


                                                        Container(
                                                          padding:
                                                          const EdgeInsets.only(top: 5.0, left: 10.0, right: 0.0,bottom: 5),
                                                          child:  Text(
                                                            Bid_Book_price2[index].toString(),
                                                            style: TextStyle(color: Colors.lightGreen, fontSize: 13),
                                                          ),
                                                        ),
                                                      ],
                                                    ),),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );

                                      },


                                      itemCount: depth_Bid,
                                    ),
                                  ),
                                ),


                                Expanded(
                                  child: Container(
                                    padding:
                                    const EdgeInsets.only(top: 10.0, bottom: 10),

                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0) //         <--- border radius here
                                      ),
                                    ),
                                    child: ListView.builder(
                                      itemBuilder: (context, index) {



                                        if(index > 0){
                                          title_order = false;
                                        }
                                        else{
                                          title_order = true;
                                        }

                                        return InkWell(
                                          onTap: (){
                                            controller.text = Ask_Book_price2[index].toString();
                                          },
                                          child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[


                                            Container(
                                              padding:
                                              const EdgeInsets.only(top: 1.0, left: 10.0, right: 10.0),
                                              child:
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[

                                                  Visibility (
                                                    visible: title_order,
                                                    child: Container(
                                                      padding:
                                                      const EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0,bottom: 5),
                                                      child:   Text(
                                                        "Price",
                                                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 16),

                                                      ),
                                                    ),
                                                    replacement: SizedBox(height: 1,),
                                                  ),

                                                  Container(
                                                    padding:
                                                    const EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0,bottom: 5),
                                                    child:  Text(

                                                      Ask_Book_price2[index].toString(),
                                                      style: TextStyle(color: Colors.red, fontSize: 13),
                                                    ),
                                                  ),


                                                ],
                                              ),
                                            ),


                                            Container(
                                              padding:
                                              const EdgeInsets.only(top: 1.0, left: 16.0, right: 25.0),
                                              child:
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[

                                                  Visibility (
                                                    visible: title_order,
                                                    child: Container(
                                                      padding:
                                                      const EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0,bottom: 5),
                                                      child:   Text(
                                                        "Total",
                                                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 16),

                                                      ),
                                                    ),
                                                    replacement: SizedBox(height: 1,),
                                                  ),

                                                  Container(
                                                    padding:
                                                    const EdgeInsets.only(top: 5.0, left: 0.0, right: 10,bottom: 5),
                                                    child:  Text(

                                                      Ask_Book_total2[index],
                                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),


                                          ],
                                        ),);

                                      },

                                      itemCount: depth_Ask,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                  );


                }
                else if(snapshot.hasData){
                  parsed = json.decode(snapshot.data);

                  try {

                    if(parsed.containsKey('version')){
                      _sendMessage();
                    }
                    else
                    if(parsed.containsKey('timestamp')){

                      if(parsed["side"] == "sell"){

                        if(Ask_Book_price.length < 10){
                          var total;
                          Ask_Book_price.add(parsed["price"].toString());
                          total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                          Ask_Book_total.add(total.toStringAsFixed(3));
                          depth_Ask = Ask_Book_price.length;
                        }
                        change_status_ask = 1;


                      }
                      else if(parsed["side"] == "buy"){
                        var total;
                        if(Bid_Book_price.length < 10){
                          Bid_Book_price.add(parsed["price"].toString());
                          total = (double.parse(parsed["qty"].toString()))/(double.parse(parsed["price"].toString()));
                          Bid_Book_total.add(total.toStringAsFixed(3));
                          depth_Bid = Bid_Book_price.length;
                        }
                        change_status_bid = 1;
                      }
                    }

                  } on Exception catch (_) {
                    print('never reached');
                  }

                  return Container(
                    width: width*0.95,
                    height: height*0.5,
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                      ],

                    ),
                  );
                }
                return SizedBox(width: 1,);

              },
            )
          ],
        ),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {

    widget.channel.sink.add('{"event":"subscribe","feed":"book","product_ids":["PI_XBTUSD"]}');

  }



  @override
  void dispose() {

    widget.channel.sink.close();
    super.dispose();
  }
}

