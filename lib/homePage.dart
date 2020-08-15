import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as ytt;
import 'package:ext_storage/ext_storage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class ytvideo {
  String adi;
  String id;
  String resim;
  String yukleyen;

  ytvideo(this.adi, this.id, this.resim, this.yukleyen);
}

class _HomePageState extends State<HomePage> {
  var myTextcontroller = TextEditingController();

  List<ytvideo> videolar = new List<ytvideo>();
  var yt = ytt.YoutubeExplode();
  Future<List<ytvideo>> mysearchfuture;

  void indir(String id, String adi) async {
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    if (streamInfo != null) {
      // Get the actual stream
      var stream = yt.videos.streamsClient.get(streamInfo);
      var path = await ExtStorage.getExternalStorageDirectory();
      // Open a file for writing.
      var file = File(path + "/Download/" + adi + ".mp3");
      var fileStream = file.openWrite();

      // Pipe all the content of the stream into the file.
      await stream.pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Done"),
          content: Text(adi + ".mp3 was saved to Download folder."),
          actions: [
            FlatButton(
              child: Text('OK.'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<List<ytvideo>> arama_yap() async {
    videolar = new List<ytvideo>();
    String query = myTextcontroller.text;
    var response = await yt.search.getVideosAsync(myTextcontroller.text);
    response.listen((event) {
      debugPrint(event.title.toString());
      setState(() {
        videolar.add(ytvideo(event.title, event.id.toString(),
            event.thumbnails.lowResUrl, event.author));
      });
    });
    debugPrint(videolar.length.toString());
    return videolar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("YT DL"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(hintText: 'Search'),
                      controller: myTextcontroller,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      child: Text("Search!"),
                      onPressed: () {
                        mysearchfuture = arama_yap();
                        //arama_yap();
                      },
                      color: Colors.redAccent,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          FutureBuilder(
            future: mysearchfuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Image.network(snapshot.data[index].resim),
                        title: Text(snapshot.data[index].adi),
                        subtitle: Text(snapshot.data[index].yukleyen),
                        onTap: () {
                          indir(snapshot.data[index].id,
                              snapshot.data[index].adi);
                        },
                      );
                    },
                  ),
                );
              } else {
                return Text("Nuri ODACI");
              }
            },
          ),
        ],
      ),
    );
  }
}
