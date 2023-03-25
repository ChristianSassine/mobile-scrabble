enum ImageType {
  DataImage('data'),
  UrlImage('url');

  const ImageType(this.value);

  static ImageType fromString(String type){
    switch(type) {
      case('data') : {
        return ImageType.DataImage;
      }
      case ('url'): {
        return ImageType.UrlImage;
      }
      default:
        return ImageType.DataImage;
    }
  }

  final String value;
}
