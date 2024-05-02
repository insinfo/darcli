import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:new_sali_backend/src/shared/app_config.dart';
//import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import "package:pointycastle/export.dart";
//import "package:asn1lib/asn1lib.dart";
import 'package:path/path.dart' as path;

/// para criar certificado
class X509CertificateService {
  static generate(String userFullName,
      {String userEmail = 'insinfo2008@gmail.com'}) {
    
    var keys = generateKeyPair();
    var caPriKey = keys.privateKey as RSAPrivateKey;
    var serverPubKey = keys.publicKey as RSAPublicKey;

    /*
      cn=AC Final do Governo Federal do Brasil v1
      ou=AC Intermediaria do Governo Federal do Brasil v1
      o=Gov-Br
      c=BR

      X509v3 Subject Alternative Name:
      othername:<unsupported>, othername:<unsupported>, othername:<unsupported>, email:insinfo2008@gmail.com
      X509v3 Basic Constraints:
      CA:FALSE
      X509v3 Authority Key Identifier:
      keyid:3C:2A:68:5C:99:84:7B:50:50:B7:3E:41:1A:A0:AD:48:37:61:B5:27
      X509v3 Certificate Policies:
      Policy: 2.16.76.3.2.1.1
      CPS: http://repo.iti.br/docs/DPCacfGovBrv1.pdf
      X509v3 CRL Distribution Points:
      Full Name:
      URI:http://repo.iti.br/lcr/public/acf/LCRacfGovBr.crl
      X509v3 Key Usage critical:
      Digital Signature
      X509v3 Extended Key Usage:
      TLS Web Client Authentication, E-mail Protection
      X509v3 Subject Key Identifier:
      38:A3:A9:2A:C9:C2:E9:8B:96:9B:25:88:51:84:6A:04:15:1B:90:86
      Authority Information Access:
      CA Issuers - URI:http://repo.iti.br/docs/Cadeia_GovBr-der.p7b
      */

    //emitido para
    Map<String, String> x509Subject = {
      'C': 'BR',
      // 'ST': 'BJ',
      // 'L': 'BJ',
      // 'O': 'network',
      // 'OU': 'Proxy',
    };
    //CN=ISAQUE NEVES SANT ANA
    x509Subject['CN'] = userFullName;

    //keyUsage=digitalSignature, dataEncipherment, keyAgreement
//1.2.840.113583.1.1.10=DER:05:00


    var csr = X509Utils.generateRsaCsrPem(x509Subject, caPriKey, serverPubKey,
        san: [userEmail]);

    //Map<String, String> issuer = Map.from(_caCert.tbsCertificate!.subject);
    var csrPem = X509Utils.generateSelfSignedCertificate(caPriKey, csr, 365,
        //Subject Alternative Name
        //sans: [host],
        serialNumber: '1',
        // emitido por
        issuer: {
          'CN': 'AC Final do Governo Federal do Brasil v1',
          'OU': 'AC Intermediaria do Governo Federal do Brasil v1',
          'O': 'Gov-Br',
          'C': 'BR'
        });
    // print(csrPem);
    var appCacheDir = AppConfig.inst().appCacheDir;
    var file = File(path.join(appCacheDir, 'certificate.crt'));
    file.writeAsStringSync(csrPem);
  }

  static AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair() {
    var keyParams =
        new RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12);

    var secureRandom = new FortunaRandom();
    var random = new Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(new KeyParameter(new Uint8List.fromList(seeds)));

    var rngParams = new ParametersWithRandom(keyParams, secureRandom);
    var k = new RSAKeyGenerator();
    k.init(rngParams);

    return k.generateKeyPair();
  }
}
