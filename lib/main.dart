import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

void main(){
  runApp(new BeKindApp());
}

//default color scheme for both IOS and ANDRIOD respectively
 final ThemeData kIOSTheme = new ThemeData(
   primarySwatch: Colors.orange,
   primaryColor: Colors.grey[100],
   primaryColorBrightness: Brightness.light,
 );

  final ThemeData kDefaultTheme = new ThemeData(
    primarySwatch: Colors.pink,
    accentColor: Colors.pinkAccent[600],
  );
// End of color Scheme for IOS and ANDROID

//  declaring, name as a variable
const String _name = "James";

class BeKindApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     return new MaterialApp(
       title: "BeKind",
       theme: defaultTargetPlatform ==TargetPlatform.iOS ? kIOSTheme : kDefaultTheme,
       home: new ChatScreen(),
     );
  }
}

// implementation of chat message list
class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController});
  final String text;
  final AnimationController animationController;
  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
        parent: animationController, curve: Curves.easeIn),
      axisAlignment: 0.0,
    child: new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(child: new Text(_name[0])),
          ),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                new Text(_name,style: Theme.of(context).textTheme.subhead),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text(text,
                  style: new TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
     ),
   );
  }
}

 class  ChatScreen extends StatefulWidget {
   @override
   State createState() => new ChatScreenState();
 }

 class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

   final TextEditingController _textController = new TextEditingController();
   final List<ChatMessage> _messages = <ChatMessage>[];
   bool _isComposing = false;
   @override
    Widget _buildTextComposer() {
     return new IconTheme(
       data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                style: new TextStyle(
                  color: Colors.white, 
                  decorationStyle: TextDecorationStyle.wavy,
                  fontSize: 18.0
                  ),
                controller: _textController,
                onChanged: (String text) => setState( ()=> _isComposing = text.length > 0),
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                  hintText: "Send a Message",
                  hintStyle: new TextStyle(color: Colors.white70)
                ),
              ),
            ),
         
        // Material-Icon send button
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
               child: Theme.of(context).platform == TargetPlatform.iOS ?
               new CupertinoButton(
                 child: new Text("Send"),
                 onPressed: _isComposing
                 ? () => _handleSubmitted(_textController.text)
                 : null,
                ) :
            new IconButton(
                icon: new Icon(Icons.send),
                color: Colors.white,
                onPressed:_isComposing ? () => _handleSubmitted(_textController.text) : null,
                // onPressed: () {return _handleSubmitted(_textController.text);} //Alternative Syntax
              ),
              
            ),
          ],
        ),
      ),
    );
   }
  
  @override
  void dispose(){
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
  }

  // clear the field on the text input field
  void _handleSubmitted(String text) {
    _textController.clear();
      setState(() => _isComposing =false);
    ChatMessage message = new ChatMessage(
      text: text,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 750),
        vsync: this,
      ),
    );
    setState(() => _messages.insert(0, message)); 
    message.animationController.forward();
  }

   Widget build(BuildContext context) {
     return new Scaffold(
         appBar:  new AppBar(
         title: new Center(
         child: new Text( "BeKind"),
         ),
         elevation: Theme.of(context).platform ==TargetPlatform.iOS ? 0.0 : 4.0,
       ), 
       
      //  body: _buildTextComposer(),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
              ),
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: new BorderRadius.all(const Radius.circular(20.0))
              ),
              child: _buildTextComposer(),
            )
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
        ? new BoxDecoration(
           border: new Border(
             top: new BorderSide(color: Colors.grey[200]),
           )
        ) 
        : null,
      ),
     );
   }
 }