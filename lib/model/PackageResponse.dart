class PackageResponse {
  String invoiceNumber;
  String packageName;
  String paymentRef;

  PackageResponse({this.invoiceNumber, this.packageName, this.paymentRef});

  PackageResponse.fromJson(Map<String, dynamic> json) {
    invoiceNumber = json['invoice_number'];
    packageName = json['package_name'];
    paymentRef = json['payment_ref'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invoice_number'] = this.invoiceNumber;
    data['package_name'] = this.packageName;
    data['payment_ref'] = this.paymentRef;
    return data;
  }
}
