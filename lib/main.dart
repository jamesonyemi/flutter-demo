import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

void main(){
  runApp(new BeKindApp());
}
bool _isComposing = false;
final TextEditingController _textController = new TextEditingController();
final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;

//default color scheme for both IOS and ANDRIOD respectively
 final ThemeData kIOSTheme = new ThemeData(
   primarySwatch: Colors.orange,
   primaryColor: Colors.grey[100],
   primaryColorBrightness: Brightness.light,
 );

  final ThemeData kDefaultTheme = new ThemeData(
    primarySwatch: Colors.pink,
    accentColor: Colors.pinkAccent[600],
    primaryColorBrightness: Brightness.dark
  );
// End of color Scheme for IOS and ANDROID

class BeKindApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     return new MaterialApp(
       debugShowCheckedModeBanner: false,
       title: "BeKind",
       theme: defaultTargetPlatform ==TargetPlatform.iOS ? kIOSTheme : kDefaultTheme,
       home: new ChatScreen(),
     );
  }
}
// implementation of chat message list
class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(borderRadius: new BorderRadius.only(topLeft: Radius.zero)),
         child: new Card(
        elevation: 4.5,
        color: const Color.fromRGBO(255, 255, 255, 1.0),
           child: new SizeTransition(
          sizeFactor: new CurvedAnimation(
            parent: animation, curve: Curves.easeIn),
          axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                  margin:new EdgeInsets.only(left: 3.5),
                  child: new Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: new CircleAvatar(
                    backgroundImage: new NetworkImage(snapshot.value['senderPhotoUrl']),
                    // child: new Text(_currentUserName[0])
                    ),
                ),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // textDirection: TextDirection.ltr,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    new Text(
                      snapshot.value['senderName'].toString(),
                      style: Theme.of(context).textTheme.subhead
                      ),
                    new Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: snapshot.value['imageUrl'] != null ?
                      new Image.network(
                        snapshot.value['imageUrl'],
                        alignment: Alignment.center,
                        fit: BoxFit.fitWidth,
                        gaplessPlayback: true,
                        repeat: ImageRepeat.noRepeat,
                        width: 250.0,
                      ):
                      new Text(snapshot.value['text'],style: new TextStyle(),),
                      // style: new TextStyle(
                      //   fontSize: 15.50,
                      //   fontWeight: FontWeight.w500,
                      //   fontFamily: 'Roboto',
                      //   ),
                      // ),
                      // child: new Text(
                      // snapshot.value['text'],
                      // style: new TextStyle(
                      //   fontSize: 15.50,
                      //   fontWeight: FontWeight.w500,
                      //   fontFamily: 'Roboto',
                      //   ),
                      // ),
                    )
                  ],
                ),
              )
            ],
          ),
         ),
       ),
     ),
   );
  }
}
 class  ChatScreen extends StatefulWidget {
   @override
   State createState() => new ChatScreenState();
 }
 class ChatScreenState extends State<ChatScreen> {
  int _counter = 0;
  ScrollController _scrollController;                                 // NEW
  @override                                                           // NEW
    void initState() {                                                // NEW
        super.initState();                                            // NEW
        _scrollController = new ScrollController(                     // NEW
          initialScrollOffset: 0.0,                                   // NEW
          keepScrollOffset: true,                                     // NEW
        );
      }
    void _toEnd() { 
        SchedulerBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(microseconds: 30),
              curve: Curves.easeOut,
            ).asStream();
          });              
    }                                                                   

   Widget _buildTextComposer() {
     return new IconTheme(
       data: new IconThemeData(color: Theme.of(context).accentColor),
       child: new Container(
       margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 250.0,
        child: new Padding(
         padding: new EdgeInsets.only(left:5.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 1.0),
                child: new IconButton(
                  icon: new Icon(Icons.photo_camera),
                  color: Colors.white,
                  padding: const EdgeInsets.only(right: 35.0),
                  onPressed: () async {
                    await _ensureLoggedIn();
                    File imageFile = await ImagePicker.pickImage();
                    int random = new Random().nextInt(100000);
                    
                    //save data into firebase database
                    StorageReference ref =
                    FirebaseStorage.instance.ref().child("image_$random.jpg");
                    StorageUploadTask uploadTask = ref.put(imageFile);
                    Uri downloadUrl = (
                    await uploadTask.future).downloadUrl;
                    _sendMessage(imageUrl: downloadUrl.toString(),
                    //timeSent: new TimeOfDay.now().format(context).toString()
                    );
                  },
                ),
              ),
              new Flexible(
                child: new Container(
                  child: new Scrollbar(
                    child: new ConstrainedBox(
                      constraints: new BoxConstraints(maxHeight: 100.0, maxWidth: 500.0),
                      child: new SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        reverse: true,
                        child: new TextField(
                          maxLines: null,
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          style: new TextStyle(
                            color: Colors.white, 
                            decorationStyle: TextDecorationStyle.wavy,
                            fontSize: 18.0
                            ),
                          controller: _textController,
                          onChanged: (String text) => setState( ()=> _isComposing = text.length > 0),
                          onSubmitted: _handleSubmitted,
                          decoration: new InputDecoration.collapsed(
                            hintText: "Type a mess...",
                            hintStyle: new TextStyle(color: Colors.white70)
                          ),
                        ),
                      ),
                    ),
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
      ),
    );
   }
final firebasedbReference = FirebaseDatabase.instance.reference().child('messages');

  // clear the field on the text input field
 Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
      setState(() => _isComposing =false);
      await _ensureLoggedIn();
      _sendMessage(text: text);
 }
    void _sendMessage({String text, String imageUrl,
    //String timeSent
    }) {
    firebasedbReference.push().set({                                 
    'text': text,
    'createdTime':new TimeOfDay.now().format(context),
    'createdDate':new DateFormat("EEEE dd MMM, y").format(new DateTime.now()),
    'imageUrl': imageUrl,                                        
    'senderName': googleSignIn.currentUser.displayName,  
    'senderPhotoUrl': googleSignIn.currentUser.photoUrl,
    //'timeSent': new TimeOfDay.now().format(context),
  }); 
    analytics.logEvent(name: 'send_message');
  }

  Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null)
    user = await googleSignIn.signInSilently();
  if (user == null) {
    await googleSignIn.signIn();
    analytics.logLogin();
  }
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
    await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken
    );
  }
}
  
   Widget build(BuildContext context) {
    List items = [];
    for (int i = 0; i < _counter; i++) {
      items.add(new Text("Item $i"));
    }
     return new Scaffold(
        appBar:  new AppBar(
        actions: <Widget>[                                            
        new IconButton(                                             
        icon: new Icon(Icons.arrow_upward), 
          onPressed: _toEnd
          )
        ], 
         centerTitle: true,
         title: new Center(
         child: new Text( "BeKind"),
         ),
         elevation: Theme.of(context).platform ==TargetPlatform.iOS ? 0.0 : 4.0,
       ), 
       
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new FirebaseAnimatedList(
                shrinkWrap: false,
                query: firebasedbReference,
                controller: _scrollController,  
                sort: (a,b) => b.key.compareTo(a.key),
                padding: new EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation) { 
                return new ChatMessage(
                  snapshot: snapshot,
                  animation:animation
                 );
                },
              ),
            ),
            
            new Container(
            child: new Divider(
            height: 2.0,
            color: Colors.white,
            ),
          ),
            new Container(
              margin: const EdgeInsets.only(right: 35.0),
              decoration: new BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: new BorderRadius.all(const Radius.circular(20.0)),
                
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