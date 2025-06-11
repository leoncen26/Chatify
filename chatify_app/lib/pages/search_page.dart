import 'package:chatify_app/models/contact.dart';
import 'package:chatify_app/pages/conversation_page.dart';
import 'package:chatify_app/providers/auth_provider.dart';
import 'package:chatify_app/services/database_service.dart';
import 'package:chatify_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchPage extends StatefulWidget {
  final double height, width;

  const SearchPage(this.height, this.width, {super.key});
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  AuthProvider? _auth;
  String? _searchText;

  _SearchPageState() {
    _searchText = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _searchPageUI(),
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(builder: (BuildContext context) {
      _auth = Provider.of<AuthProvider>(context);
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _searchField(),
          _userListView(),
        ],
      );
    });
  }

  Widget _searchField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: widget.height * 0.02),
      height: widget.height * 0.08,
      width: widget.width,
      child: TextField(
        autocorrect: false,
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        onSubmitted: (_input) {
          setState(() {
            _searchText = _input;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          labelText: 'Search',
          labelStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _userListView() {
    return StreamBuilder<List<Contact>>(
      stream: DatabaseService.instance.getUserInDB(_searchText!),
      builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
        var dataUser = snapshot.data;
        if (dataUser != null) {
          dataUser.removeWhere((_contact) => _contact.id == _auth!.user!.uid);
        }
        return snapshot.hasData
            ? Expanded(
                child: ListView.builder(
                  itemCount: dataUser!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var userData = dataUser[index];
                    var recepientID = dataUser[index].id;
                    var isUserActive = !userData.lastSeen.toDate().isBefore(
                          DateTime.now().subtract(
                            Duration(
                              minutes: 1,
                            ),
                          ),
                        );
                    return ListTile(
                      onTap: () {
                        DatabaseService.instance.createOrGetConversation(
                          _auth!.user!.uid,
                          recepientID,
                          (String conversationID) async {
                            NavigationService.instance.navigateToRoute(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return ConversationPage(
                                    conversationID,
                                    recepientID,
                                    dataUser[index].image,
                                    dataUser[index].name,
                                  );
                                },
                              ),
                            );
                            return;
                          },
                        );
                      },
                      title: Text(userData.name),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              userData.image,
                            ),
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          isUserActive
                              ? Text(
                                  'Active Now',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                )
                              : Text(
                                  'Last Seen',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                          isUserActive
                              ? Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                )
                              : Text(
                                  timeago.format(
                                    userData.lastSeen.toDate(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : SpinKitWanderingCubes(
                color: Colors.blue,
                size: 50.0,
              );
      },
    );
  }
}
