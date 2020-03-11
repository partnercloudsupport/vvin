class CurrentIndex {
  int index;
  CurrentIndex({this.index});
}

class EditCompanyDetails {
  String companyID, userID, level, userType, image, name, phone, email, website, address;
  EditCompanyDetails(
      {this.companyID,
      this.userID,
      this.level,
      this.userType,
      this.image,
      this.name,
      this.phone,
      this.email,
      this.website,
      this.address});
}

class Noti {
  String title, subtitle, date, notiID, status;
  Noti({this.title, this.subtitle, this.date, this.notiID, this.status});
}

class Myworks {
  String date, title, link, category, qr, url, urlName, id, priority;
  bool offLine;
  List handlers;
  Myworks({this.date, this.title, this.link, this.category, this.qr, this.url, this.urlName, this.offLine, this.id, this.handlers, this.priority});
}

class TopView {
  String name, status, channel, views, phoneNo;
  TopView({this.name, this.status, this.channel, this.views, this.phoneNo});
}

class LeadData {
  String date, number;
  LeadData({this.date, this.number});
}

class VDataDetails {
  String companyID,
      userID,
      level,
      userType,
      date,
      name,
      phoneNo,
      handler,
      remark,
      status,
      type,
      app,
      channel,
      link,
      fromVAnalytics;
  VDataDetails(
      {this.companyID,
      this.userID,
      this.level,
      this.userType,
      this.date,
      this.name,
      this.phoneNo,
      this.handler,
      this.remark,
      this.status,
      this.app,
      this.type,
      this.channel,
      this.link,
      this.fromVAnalytics});
}

class Link {
  String link, type;
  Link({this.link, this.type});
}

class VProfileData {
  String name, 
      email,
      company,
      ic,
      dob,
      gender,
      position,
      industry,
      occupation,
      country,
      state,
      area,
      app,
      channel,
      created,
      lastActive,
      img;
  VProfileData(
      {this.name, 
      this.email,
      this.company,
      this.ic,
      this.dob,
      this.gender,
      this.position,
      this.industry,
      this.occupation,
      this.country,
      this.state,
      this.area,
      this.app,
      this.channel,
      this.created,
      this.lastActive,
      this.img});
}

class View{
  String date, link;
  View({this.date, this.link});
}

class Remarks{
  String date, remark, system;
  Remarks({this.date, this.remark, this.system});
}

class Gender{
  String gender;
  int position;
  Gender({this.gender, this.position});
}

class Handler{
  String handler, handlerID;
  int position;
  Handler({this.handler, this.handlerID, this.position});
}

class Industry{
  String industry;
  int position;
  Industry({this.industry, this.position});
}

class Country{
  String country;
  int position;
  Country({this.country, this.position});
}

class States{
  String state;
  int position;
  States({this.state, this.position});
}

class NotificationDetail{
  String title, subtitle1, subtitle2;
  NotificationDetail({this.title, this.subtitle1, this.subtitle2});
}

class Links{
  String link_type, link, link_id;
  int position;
  Links({this.link_type, this.link, this.link_id, this.position});
}

class VDataFilter{
  String startDate, endDate, type, status, app, channel;
  VDataFilter({this.startDate, this.endDate, this.type, this.status, this.app, this.channel});
}

class Setting{
  String assign, unassign, userID, companyID, level, userType;
  Setting({this.assign, this.unassign, this.userID, this.companyID, this.level, this.userType});
}

class WhatsappForward{
  String url, userID, companyID, level, userType;
  List vtagList;
  WhatsappForward({this.url, this.userID, this.companyID, this.level, this.userType, this.vtagList});
}