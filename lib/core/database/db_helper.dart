import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._internal();

  static final DbHelper instance = DbHelper._internal();
  static const String _databaseName = 'kopi_quiz.db';
  static const String _tableName = 'questions';

  Database? _database;

  static const List<Map<String, String>> _seedQuestions = [
    {
      'question':
          'Spesies kopi yang biasanya memiliki kafein lebih tinggi adalah...',
      'option_a': 'Arabika',
      'option_b': 'Robusta',
      'option_c': 'Liberika',
      'option_d': 'Excelsa',
      'correct_answer': 'B',
    },
    {
      'question':
          'Wilayah asal tanaman kopi Arabika yang paling umum diterima adalah...',
      'option_a': 'Ethiopia',
      'option_b': 'Brasil',
      'option_c': 'Kolombia',
      'option_d': 'Vietnam',
      'correct_answer': 'A',
    },
    {
      'question': 'Rasio seduh 1:16 berarti...',
      'option_a': '1 gram air untuk 16 gram kopi',
      'option_b': '1 gram kopi untuk 16 gram air',
      'option_c': '16 gram kopi untuk 1 gram air',
      'option_d': '16 menit untuk 1 gram kopi',
      'correct_answer': 'B',
    },
    {
      'question': 'Gilingan yang umum digunakan untuk French Press adalah...',
      'option_a': 'Sangat halus',
      'option_b': 'Halus',
      'option_c': 'Sedang',
      'option_d': 'Kasar',
      'correct_answer': 'D',
    },
    {
      'question': 'Blooming pada pour-over bertujuan terutama untuk...',
      'option_a': 'Mendinginkan air',
      'option_b': 'Melepaskan gas CO2',
      'option_c': 'Menambah kafein',
      'option_d': 'Mengurangi berat kopi',
      'correct_answer': 'B',
    },
    {
      'question': 'Suhu air yang lazim digunakan untuk pour-over adalah...',
      'option_a': '60–70°C',
      'option_b': '75–80°C',
      'option_c': '90–96°C',
      'option_d': '105–115°C',
      'correct_answer': 'C',
    },
    {
      'question': 'Kopi yang terasa sangat asam dan tipis dapat menunjukkan...',
      'option_a': 'Over-extraction',
      'option_b': 'Under-extraction',
      'option_c': 'Terlalu banyak crema',
      'option_d': 'Air terlalu keras selalu',
      'correct_answer': 'B',
    },
    {
      'question':
          'Rasa pahit, kering, dan sepat yang dominan sering menandakan...',
      'option_a': 'Under-extraction',
      'option_b': 'Over-extraction',
      'option_c': 'Biji belum digiling',
      'option_d': 'Blooming terlalu singkat saja',
      'correct_answer': 'B',
    },
    {
      'question': 'Crema pada espresso terbentuk terutama dari...',
      'option_a': 'Minyak dan CO2 terlarut',
      'option_b': 'Gula tambahan',
      'option_c': 'Susu yang menguap',
      'option_d': 'Ampas yang terbakar',
      'correct_answer': 'A',
    },
    {
      'question':
          'Waktu ekstraksi espresso yang sering dijadikan titik awal adalah...',
      'option_a': '5–8 detik',
      'option_b': '25–30 detik',
      'option_c': '2–3 menit',
      'option_d': '10 menit',
      'correct_answer': 'B',
    },
    {
      'question': 'Tamping pada espresso dilakukan untuk...',
      'option_a': 'Meratakan puck kopi',
      'option_b': 'Mendinginkan portafilter',
      'option_c': 'Mengaduk susu',
      'option_d': 'Mengurangi ukuran cangkir',
      'correct_answer': 'A',
    },
    {
      'question': 'Channeling terjadi ketika...',
      'option_a': 'Air mencari jalur melalui puck yang tidak merata',
      'option_b': 'Susu membentuk microfoam',
      'option_c': 'Biji disimpan kedap udara',
      'option_d': 'Filter kertas dilipat',
      'correct_answer': 'A',
    },
    {
      'question': 'Kertas filter V60 umumnya menghasilkan seduhan dengan...',
      'option_a': 'Sedimen sangat tinggi',
      'option_b': 'Kejernihan tinggi',
      'option_c': 'Body seperti espresso',
      'option_d': 'Rasa asin dominan',
      'correct_answer': 'B',
    },
    {
      'question': 'Chemex menggunakan filter yang biasanya...',
      'option_a': 'Lebih tebal sehingga banyak minyak tertahan',
      'option_b': 'Tidak perlu dibasahi',
      'option_c': 'Terbuat dari logam',
      'option_d': 'Tidak memiliki pori',
      'correct_answer': 'A',
    },
    {
      'question': 'Aeropress mengekstraksi kopi dengan kombinasi...',
      'option_a': 'Immersion dan tekanan',
      'option_b': 'Api langsung dan vakum',
      'option_c': 'Sentrifugasi dan gas',
      'option_d': 'Fermentasi dan pembekuan',
      'correct_answer': 'A',
    },
    {
      'question':
          'Cold brew berbeda dari iced coffee karena cold brew umumnya...',
      'option_a': 'Diseduh dingin dalam waktu lama',
      'option_b': 'Selalu memakai espresso',
      'option_c': 'Tidak mengandung air',
      'option_d': 'Wajib disajikan panas',
      'correct_answer': 'A',
    },
    {
      'question': 'Syphon brewer memanfaatkan prinsip...',
      'option_a': 'Tekanan uap dan vakum',
      'option_b': 'Pembakaran biji',
      'option_c': 'Karbonasi',
      'option_d': 'Pembekuan cepat',
      'correct_answer': 'A',
    },
    {
      'question': 'Moka pot menghasilkan minuman yang...',
      'option_a': 'Mirip espresso namun bukan espresso mesin',
      'option_b': 'Selalu tanpa kafein',
      'option_c': 'Hanya dapat dibuat dingin',
      'option_d': 'Tidak melewati bed kopi',
      'correct_answer': 'A',
    },
    {
      'question': 'TDS pada kopi mengacu pada...',
      'option_a': 'Total zat terlarut',
      'option_b': 'Total dosis seduhan',
      'option_c': 'Temperatur distribusi seduh',
      'option_d': 'Tekanan steam wand',
      'correct_answer': 'A',
    },
    {
      'question': 'Extraction yield menunjukkan...',
      'option_a': 'Persentase massa kopi yang larut ke air',
      'option_b': 'Berat cangkir kosong',
      'option_c': 'Lama roasting',
      'option_d': 'Kadar minyak grinder',
      'correct_answer': 'A',
    },
    {
      'question': 'Light roast biasanya lebih banyak mempertahankan...',
      'option_a': 'Karakter origin dan keasaman',
      'option_b': 'Rasa gosong',
      'option_c': 'Minyak di permukaan',
      'option_d': 'Kepahitan arang',
      'correct_answer': 'A',
    },
    {
      'question': 'First crack pada roasting menandakan...',
      'option_a': 'Pelepasan uap dan ekspansi biji',
      'option_b': 'Biji menjadi bubuk',
      'option_c': 'Kopi selesai diseduh',
      'option_d': 'Air mendidih',
      'correct_answer': 'A',
    },
    {
      'question': 'Development time dalam roasting adalah waktu setelah...',
      'option_a': 'First crack dimulai',
      'option_b': 'Biji dipanen',
      'option_c': 'Kopi digiling',
      'option_d': 'Cangkir dicuci',
      'correct_answer': 'A',
    },
    {
      'question': 'Degassing adalah proses ketika biji sangrai...',
      'option_a': 'Melepaskan CO2',
      'option_b': 'Menyerap semua air',
      'option_c': 'Menjadi hijau kembali',
      'option_d': 'Membentuk crema',
      'correct_answer': 'A',
    },
    {
      'question': 'Grinder burr lebih disukai daripada blade karena...',
      'option_a': 'Ukuran gilingan lebih konsisten',
      'option_b': 'Selalu lebih murah',
      'option_c': 'Tidak menghasilkan panas',
      'option_d': 'Tidak perlu dibersihkan',
      'correct_answer': 'A',
    },
    {
      'question': 'Fines adalah partikel kopi yang...',
      'option_a': 'Sangat kecil',
      'option_b': 'Paling besar',
      'option_c': 'Belum disangrai',
      'option_d': 'Terbuat dari filter',
      'correct_answer': 'A',
    },
    {
      'question':
          'Rasio espresso 1:2 berarti 18 gram kopi menghasilkan sekitar...',
      'option_a': '9 gram minuman',
      'option_b': '18 gram minuman',
      'option_c': '36 gram minuman',
      'option_d': '72 gram minuman',
      'correct_answer': 'C',
    },
    {
      'question': 'Pre-infusion pada mesin espresso berfungsi untuk...',
      'option_a': 'Membasahi puck sebelum tekanan penuh',
      'option_b': 'Mendinginkan boiler',
      'option_c': 'Mengeringkan kopi',
      'option_d': 'Menghentikan pompa',
      'correct_answer': 'A',
    },
    {
      'question':
          'Tekanan nominal yang sering digunakan pada espresso modern sekitar...',
      'option_a': '2 bar',
      'option_b': '9 bar',
      'option_c': '30 bar',
      'option_d': '100 bar',
      'correct_answer': 'B',
    },
    {
      'question': 'Susu untuk latte art membutuhkan microfoam dengan...',
      'option_a': 'Gelembung sangat halus dan tekstur mengilap',
      'option_b': 'Gelembung besar dan kering',
      'option_c': 'Tidak ada udara sama sekali',
      'option_d': 'Busa sabun',
      'correct_answer': 'A',
    },
    {
      'question': 'Steam wand sebaiknya dipurge untuk...',
      'option_a': 'Mengeluarkan kondensasi dan membersihkan susu',
      'option_b': 'Menaikkan dosis espresso',
      'option_c': 'Mendinginkan susu',
      'option_d': 'Membuat air soda',
      'correct_answer': 'A',
    },
    {
      'question': 'Proses washed pada kopi cenderung menonjolkan...',
      'option_a': 'Kejernihan karakter origin',
      'option_b': 'Rasa asap',
      'option_c': 'Rasa asin',
      'option_d': 'Body fermentasi paling berat',
      'correct_answer': 'A',
    },
    {
      'question': 'Pada proses natural, buah kopi dikeringkan...',
      'option_a': 'Bersama buah yang masih menyelimuti biji',
      'option_b': 'Setelah disangrai',
      'option_c': 'Di dalam susu',
      'option_d': 'Tanpa terkena udara',
      'correct_answer': 'A',
    },
    {
      'question': 'Honey process berarti...',
      'option_a': 'Mucilage sebagian dibiarkan saat pengeringan',
      'option_b': 'Kopi dicampur madu setelah disangrai',
      'option_c': 'Biji direndam sirup',
      'option_d': 'Biji disimpan di sarang lebah',
      'correct_answer': 'A',
    },
    {
      'question': 'Coffee cherry adalah istilah untuk...',
      'option_a': 'Buah kopi',
      'option_b': 'Biji kopi sangrai',
      'option_c': 'Filter kopi',
      'option_d': 'Ampas kopi',
      'correct_answer': 'A',
    },
    {
      'question': 'Parchment pada kopi merupakan...',
      'option_a': 'Lapisan pelindung biji',
      'option_b': 'Lapisan crema',
      'option_c': 'Kertas seduh',
      'option_d': 'Kulit buah segar',
      'correct_answer': 'A',
    },
    {
      'question': 'Coffee belt berada di antara...',
      'option_a': 'Tropic of Cancer dan Tropic of Capricorn',
      'option_b': 'Kutub Utara dan Kutub Selatan',
      'option_c': 'Eropa dan Asia',
      'option_d': 'Gurun Sahara dan Gobi',
      'correct_answer': 'A',
    },
    {
      'question':
          'Produsen kopi terbesar berdasarkan volume historis adalah...',
      'option_a': 'Brasil',
      'option_b': 'Islandia',
      'option_c': 'Kanada',
      'option_d': 'Jepang',
      'correct_answer': 'A',
    },
    {
      'question': 'Kopi Gayo dikenal berasal dari...',
      'option_a': 'Aceh',
      'option_b': 'Bali',
      'option_c': 'Jawa Timur',
      'option_d': 'Papua Nugini',
      'correct_answer': 'A',
    },
    {
      'question': 'Kopi Toraja terutama dikaitkan dengan...',
      'option_a': 'Sulawesi Selatan',
      'option_b': 'Sumatra Utara',
      'option_c': 'Jawa Barat',
      'option_d': 'Kalimantan Timur',
      'correct_answer': 'A',
    },
    {
      'question': 'Ketinggian tanam yang lebih tinggi sering menghasilkan...',
      'option_a': 'Pematangan lambat dan keasaman kompleks',
      'option_b': 'Kafein nol',
      'option_c': 'Biji tanpa aroma',
      'option_d': 'Buah tanpa daging',
      'correct_answer': 'A',
    },
    {
      'question': 'Tanaman kopi termasuk famili...',
      'option_a': 'Rubiaceae',
      'option_b': 'Fabaceae',
      'option_c': 'Poaceae',
      'option_d': 'Rosaceae',
      'correct_answer': 'A',
    },
    {
      'question': 'Kopi peaberry adalah biji yang...',
      'option_a': 'Tumbuh tunggal dan berbentuk lebih bulat',
      'option_b': 'Selalu berasal dari Robusta',
      'option_c': 'Belum pernah disangrai',
      'option_d': 'Dicampur kacang',
      'correct_answer': 'A',
    },
    {
      'question': 'Kafein pada tanaman kopi berfungsi sebagai...',
      'option_a': 'Pertahanan terhadap hama',
      'option_b': 'Pengganti air',
      'option_c': 'Pewarna buah',
      'option_d': 'Sumber minyak utama',
      'correct_answer': 'A',
    },
    {
      'question': 'Kopi decaf adalah kopi yang...',
      'option_a': 'Sebagian besar kafeinnya dihilangkan',
      'option_b': 'Tidak berasal dari tanaman kopi',
      'option_c': 'Selalu dark roast',
      'option_d': 'Mengandung alkohol',
      'correct_answer': 'A',
    },
    {
      'question': 'Metode Swiss Water menggunakan...',
      'option_a': 'Air dan karbon untuk memisahkan kafein',
      'option_b': 'Garam dapur',
      'option_c': 'Susu panas',
      'option_d': 'Pembakaran langsung',
      'correct_answer': 'A',
    },
    {
      'question': 'Wadah terbaik untuk menyimpan biji sangrai adalah...',
      'option_a': 'Kedap udara, gelap, dan sejuk',
      'option_b': 'Terbuka di bawah matahari',
      'option_c': 'Berisi air',
      'option_d': 'Tanpa penutup di tempat panas',
      'correct_answer': 'A',
    },
    {
      'question': 'Valve satu arah pada kemasan kopi memungkinkan...',
      'option_a': 'CO2 keluar dan oksigen sulit masuk',
      'option_b': 'Air masuk ke biji',
      'option_c': 'Kopi keluar otomatis',
      'option_d': 'Biji tetap basah',
      'correct_answer': 'A',
    },
    {
      'question': 'Kopi bubuk lebih cepat kehilangan kesegaran karena...',
      'option_a': 'Luas permukaan kontak udara lebih besar',
      'option_b': 'Kafeinnya langsung hilang',
      'option_c': 'Biji berubah menjadi gula',
      'option_d': 'Warna bubuk lebih gelap',
      'correct_answer': 'A',
    },
    {
      'question':
          'Air dengan alkalinitas terlalu tinggi dapat membuat kopi terasa...',
      'option_a': 'Datar dan kurang cerah',
      'option_b': 'Selalu lebih asam',
      'option_c': 'Berkarbonasi',
      'option_d': 'Seperti susu',
      'correct_answer': 'A',
    },
    {
      'question':
          'Mineral yang berpengaruh besar pada ekstraksi kopi adalah...',
      'option_a': 'Kalsium dan magnesium',
      'option_b': 'Emas dan perak',
      'option_c': 'Besi murni saja',
      'option_d': 'Timah dan seng',
      'correct_answer': 'A',
    },
    {
      'question': 'Filter logam biasanya menghasilkan seduhan dengan...',
      'option_a': 'Body lebih tebal dan lebih banyak minyak',
      'option_b': 'Tidak ada minyak sama sekali',
      'option_c': 'Sedimen nol',
      'option_d': 'Rasa selalu manis',
      'correct_answer': 'A',
    },
    {
      'question': 'Metode immersion berarti kopi...',
      'option_a': 'Terendam dalam air selama periode tertentu',
      'option_b': 'Hanya disentuh air sekali',
      'option_c': 'Diseduh tanpa cairan',
      'option_d': 'Dipanaskan tanpa air',
      'correct_answer': 'A',
    },
    {
      'question': 'Pulse pouring berarti...',
      'option_a': 'Menuang air dalam beberapa tahap',
      'option_b': 'Menuang sekali tanpa jeda',
      'option_c': 'Menggunakan air soda',
      'option_d': 'Menyeduh tanpa filter',
      'correct_answer': 'A',
    },
    {
      'question': 'Drawdown pada pour-over adalah...',
      'option_a': 'Waktu air mengalir melewati bed kopi',
      'option_b': 'Waktu roasting',
      'option_c': 'Waktu menyimpan biji',
      'option_d': 'Waktu memanaskan cangkir',
      'correct_answer': 'A',
    },
    {
      'question': 'Membilas filter kertas membantu...',
      'option_a': 'Mengurangi rasa kertas dan memanaskan brewer',
      'option_b': 'Menambah kafein',
      'option_c': 'Mengganti dosis kopi',
      'option_d': 'Mengeraskan air',
      'correct_answer': 'A',
    },
    {
      'question': 'Preheating cangkir dilakukan untuk...',
      'option_a': 'Mengurangi kehilangan panas saat penyajian',
      'option_b': 'Membuat kopi selalu pahit',
      'option_c': 'Menghilangkan crema',
      'option_d': 'Mengubah Arabika menjadi Robusta',
      'correct_answer': 'A',
    },
    {
      'question': 'Body pada deskripsi kopi berarti...',
      'option_a': 'Sensasi berat atau tekstur di mulut',
      'option_b': 'Warna kemasan',
      'option_c': 'Ukuran biji',
      'option_d': 'Suhu ruangan',
      'correct_answer': 'A',
    },
    {
      'question': 'Aftertaste adalah...',
      'option_a': 'Rasa dan aroma yang tertinggal setelah ditelan',
      'option_b': 'Rasa sebelum diseduh',
      'option_c': 'Air bilasan filter',
      'option_d': 'Waktu blooming',
      'correct_answer': 'A',
    },
    {
      'question': 'Balance dalam cupping berarti...',
      'option_a': 'Elemen rasa saling mendukung',
      'option_b': 'Kopi harus terasa asin',
      'option_c': 'Berat kopi sama dengan air',
      'option_d': 'Cangkir tidak boleh dipindah',
      'correct_answer': 'A',
    },
    {
      'question': 'SCA Flavor Wheel digunakan sebagai...',
      'option_a': 'Referensi kosakata rasa dan aroma',
      'option_b': 'Alat penggiling',
      'option_c': 'Timbangan digital',
      'option_d': 'Filter logam',
      'correct_answer': 'A',
    },
    {
      'question': 'Slurping saat cupping membantu...',
      'option_a': 'Menyebarkan kopi dan aroma ke seluruh mulut',
      'option_b': 'Mendinginkan roaster',
      'option_c': 'Mengurangi dosis',
      'option_d': 'Membuat crema',
      'correct_answer': 'A',
    },
    {
      'question': 'Quaker adalah biji sangrai yang...',
      'option_a': 'Tetap pucat karena tidak berkembang sempurna',
      'option_b': 'Terlalu gosong',
      'option_c': 'Sudah menjadi bubuk',
      'option_d': 'Mengandung gula tambahan',
      'correct_answer': 'A',
    },
    {
      'question': 'Green coffee berarti...',
      'option_a': 'Biji kopi yang belum disangrai',
      'option_b': 'Kopi dengan pewarna hijau',
      'option_c': 'Kopi basi',
      'option_d': 'Minuman matcha',
      'correct_answer': 'A',
    },
    {
      'question': 'Roast profile adalah...',
      'option_a': 'Catatan suhu dan waktu selama roasting',
      'option_b': 'Daftar menu kedai',
      'option_c': 'Ukuran filter',
      'option_d': 'Rasio susu',
      'correct_answer': 'A',
    },
    {
      'question': 'Agtron membantu menilai...',
      'option_a': 'Tingkat warna atau kegelapan roasting',
      'option_b': 'Kekerasan air',
      'option_c': 'Tekanan espresso',
      'option_d': 'Kelembapan susu',
      'correct_answer': 'A',
    },
    {
      'question':
          'Dosis, yield, dan waktu merupakan parameter penting untuk...',
      'option_a': 'Mengevaluasi ekstraksi espresso',
      'option_b': 'Menentukan warna cangkir',
      'option_c': 'Mengukur kelembapan ruangan',
      'option_d': 'Mendesain label',
      'correct_answer': 'A',
    },
    {
      'question': 'Yield espresso adalah...',
      'option_a': 'Berat minuman yang keluar',
      'option_b': 'Berat biji sebelum roasting',
      'option_c': 'Jumlah crema',
      'option_d': 'Tekanan tamping',
      'correct_answer': 'A',
    },
    {
      'question': 'WDT pada espresso digunakan untuk...',
      'option_a': 'Memecah clump dan meratakan bubuk',
      'option_b': 'Mengukur suhu air',
      'option_c': 'Mengukus susu',
      'option_d': 'Membersihkan group head',
      'correct_answer': 'A',
    },
    {
      'question': 'Bottomless portafilter berguna untuk...',
      'option_a': 'Melihat indikasi channeling',
      'option_b': 'Menaikkan suhu susu',
      'option_c': 'Menyaring cold brew',
      'option_d': 'Menimbang biji',
      'correct_answer': 'A',
    },
    {
      'question': 'Group head pada mesin espresso adalah tempat...',
      'option_a': 'Portafilter terpasang dan air ekstraksi keluar',
      'option_b': 'Susu disimpan',
      'option_c': 'Biji disangrai',
      'option_d': 'Filter dikeringkan',
      'correct_answer': 'A',
    },
    {
      'question': 'Backflushing mesin espresso dilakukan untuk...',
      'option_a': 'Membersihkan jalur dan group head',
      'option_b': 'Memperhalus biji',
      'option_c': 'Mengurangi kafein',
      'option_d': 'Mendinginkan boiler',
      'correct_answer': 'A',
    },
    {
      'question': 'Microfoam yang baik untuk latte art memiliki...',
      'option_a': 'Gelembung sangat halus dan tekstur mengilap',
      'option_b': 'Gelembung besar dan kering',
      'option_c': 'Busa sabun',
      'option_d': 'Tidak ada tekstur',
      'correct_answer': 'A',
    },
    {
      'question': 'Latte biasanya memiliki lebih banyak...',
      'option_a': 'Steamed milk',
      'option_b': 'Bubuk kopi kering',
      'option_c': 'Air soda',
      'option_d': 'Crema tanpa susu',
      'correct_answer': 'A',
    },
    {
      'question': 'Macchiato secara tradisional berarti espresso yang...',
      'option_a': 'Diberi sedikit tanda atau busa susu',
      'option_b': 'Dicampur banyak air',
      'option_c': 'Didinginkan dengan nitrogen',
      'option_d': 'Diberi sirup wajib',
      'correct_answer': 'A',
    },
    {
      'question': 'Affogato biasanya terdiri dari...',
      'option_a': 'Espresso di atas gelato',
      'option_b': 'Cold brew dan tonik',
      'option_c': 'Filter coffee dan garam',
      'option_d': 'Susu panas dan teh',
      'correct_answer': 'A',
    },
    {
      'question':
          'Espresso tonic paling cocok memakai espresso dengan karakter...',
      'option_a': 'Fruity dan cerah',
      'option_b': 'Sangat gosong',
      'option_c': 'Tanpa aroma',
      'option_d': 'Asin',
      'correct_answer': 'A',
    },
    {
      'question':
          'Kopi yang disimpan terlalu lama setelah digiling cenderung...',
      'option_a': 'Lebih cepat teroksidasi',
      'option_b': 'Menjadi lebih segar',
      'option_c': 'Kehilangan seluruh air',
      'option_d': 'Berubah menjadi Robusta',
      'correct_answer': 'A',
    },
    {
      'question':
          'Jika aliran V60 terlalu cepat, penyesuaian awal yang logis adalah...',
      'option_a': 'Memperhalus gilingan',
      'option_b': 'Memperkasar gilingan',
      'option_c': 'Menghapus blooming',
      'option_d': 'Mengurangi semua air',
      'correct_answer': 'A',
    },
    {
      'question':
          'Jika aliran V60 terlalu lambat dan rasanya pahit, penyesuaian awal adalah...',
      'option_a': 'Memperkasar gilingan',
      'option_b': 'Memperhalus gilingan',
      'option_c': 'Menambah agitasi',
      'option_d': 'Menaikkan suhu tanpa batas',
      'correct_answer': 'A',
    },
    {
      'question': 'Bypass pada seduhan berarti...',
      'option_a': 'Air melewati kopi tanpa mengekstraknya langsung',
      'option_b': 'Air mendidih dua kali',
      'option_c': 'Kopi melewati grinder',
      'option_d': 'Susu melewati steam wand',
      'correct_answer': 'A',
    },
    {
      'question': 'Timbangan dengan timer membantu barista memantau...',
      'option_a': 'Dosis, yield, dan waktu seduh',
      'option_b': 'Warna biji sebelum panen',
      'option_c': 'Kelembapan udara saja',
      'option_d': 'Jumlah kursi kedai',
      'correct_answer': 'A',
    },
    {
      'question': 'Dial-in espresso berarti...',
      'option_a': 'Menyesuaikan parameter menuju rasa target',
      'option_b': 'Menghidupkan lampu kedai',
      'option_c': 'Mencuci cangkir',
      'option_d': 'Membeli biji tanpa mencicipi',
      'correct_answer': 'A',
    },
    {
      'question': 'Konsistensi resep seduh penting agar...',
      'option_a': 'Perubahan rasa dapat ditelusuri',
      'option_b': 'Semua kopi pasti terasa sama',
      'option_c': 'Biji tidak perlu disimpan',
      'option_d': 'Air tidak perlu ditimbang',
      'correct_answer': 'A',
    },
    {
      'question':
          'Suhu susu yang terlalu tinggi cenderung menghasilkan rasa...',
      'option_a': 'Gosong dan kehilangan karakter',
      'option_b': 'Lebih segar',
      'option_c': 'Seperti buah',
      'option_d': 'Tidak berubah',
      'correct_answer': 'A',
    },
    {
      'question': 'Steam wand dipurge setelah steaming untuk...',
      'option_a': 'Membersihkan sisa susu dari ujung wand',
      'option_b': 'Menambah kafein',
      'option_c': 'Membuat kopi dingin',
      'option_d': 'Mengurangi dosis espresso',
      'correct_answer': 'A',
    },
    {
      'question': 'Espresso machine menggunakan tekanan untuk...',
      'option_a': 'Mendorong air melewati puck kopi',
      'option_b': 'Membekukan biji',
      'option_c': 'Mengeringkan filter',
      'option_d': 'Menghilangkan semua minyak',
      'correct_answer': 'A',
    },
    {
      'question':
          'Filter kertas yang lebih tebal biasanya menahan lebih banyak...',
      'option_a': 'Minyak dan sedimen',
      'option_b': 'Kafein',
      'option_c': 'Air panas',
      'option_d': 'Gas CO2 dalam biji',
      'correct_answer': 'A',
    },
    {
      'question': 'Agitasi berlebihan pada pour-over dapat...',
      'option_a': 'Meningkatkan ekstraksi dan memperlambat aliran',
      'option_b': 'Menghilangkan semua rasa',
      'option_c': 'Menurunkan suhu ke nol',
      'option_d': 'Membuat espresso',
      'correct_answer': 'A',
    },
    {
      'question': 'Cupping dilakukan terutama untuk...',
      'option_a': 'Membandingkan karakter kopi secara konsisten',
      'option_b': 'Membuat latte art',
      'option_c': 'Mengukur tekanan mesin',
      'option_d': 'Menyimpan biji',
      'correct_answer': 'A',
    },
    {
      'question': 'Aroma floral dan citrus pada kopi merupakan...',
      'option_a': 'Deskriptor sensorik',
      'option_b': 'Bahan tambahan wajib',
      'option_c': 'Jenis grinder',
      'option_d': 'Ukuran filter',
      'correct_answer': 'A',
    },
    {
      'question': 'Acidity dalam kopi paling tepat dipahami sebagai...',
      'option_a': 'Kesan keasaman yang memberi kecerahan',
      'option_b': 'Rasa asam busuk selalu',
      'option_c': 'Kadar air',
      'option_d': 'Jumlah crema',
      'correct_answer': 'A',
    },
    {
      'question': 'Penyeduhan cold brew biasanya berlangsung...',
      'option_a': 'Berjam-jam pada suhu rendah',
      'option_b': 'Kurang dari satu detik',
      'option_c': 'Dengan api langsung',
      'option_d': 'Tanpa air',
      'correct_answer': 'A',
    },
    {
      'question': 'Cold brew concentrate biasanya dibuat lebih...',
      'option_a': 'Pekat lalu diencerkan saat disajikan',
      'option_b': 'Encer daripada air putih',
      'option_c': 'Asin daripada espresso',
      'option_d': 'Panas daripada pour-over',
      'correct_answer': 'A',
    },
    {
      'question': 'Moka pot sebaiknya diangkat dari panas ketika...',
      'option_a': 'Aliran mulai memucat dan mendesis',
      'option_b': 'Air belum masuk ke basket',
      'option_c': 'Biji baru digiling',
      'option_d': 'Cangkir sudah dicuci',
      'correct_answer': 'A',
    },
    {
      'question':
          'Rasa roast yang sangat dominan biasanya lebih sering ditemukan pada...',
      'option_a': 'Dark roast',
      'option_b': 'Light roast',
      'option_c': 'Biji hijau',
      'option_d': 'Kopi tanpa roasting',
      'correct_answer': 'A',
    },
    {
      'question': 'Tujuan resting biji setelah roasting adalah...',
      'option_a': 'Memberi waktu pelepasan CO2',
      'option_b': 'Menaikkan kadar air',
      'option_c': 'Mengubah spesies kopi',
      'option_d': 'Membuat biji matang',
      'correct_answer': 'A',
    },
    {
      'question': 'Ukuran screen pada kopi menunjukkan...',
      'option_a': 'Ukuran fisik biji',
      'option_b': 'Kadar kafein langsung',
      'option_c': 'Tingkat keasaman',
      'option_d': 'Waktu seduh',
      'correct_answer': 'A',
    },
    {
      'question': 'Air seduh yang terlalu lunak dapat membuat ekstraksi...',
      'option_a': 'Kurang efektif atau terasa datar',
      'option_b': 'Selalu terlalu pahit',
      'option_c': 'Berkarbonasi',
      'option_d': 'Tidak membutuhkan kopi',
      'correct_answer': 'A',
    },
    {
      'question':
          'Air yang terlalu panas saat menyeduh dapat meningkatkan risiko...',
      'option_a': 'Over-extraction',
      'option_b': 'Biji kembali hijau',
      'option_c': 'Kopi tidak larut',
      'option_d': 'Filter berubah menjadi logam',
      'correct_answer': 'A',
    },
    {
      'question': 'Server kopi berfungsi untuk...',
      'option_a': 'Menampung hasil seduhan',
      'option_b': 'Menggiling biji',
      'option_c': 'Menekan puck',
      'option_d': 'Mengukur kelembapan',
      'correct_answer': 'A',
    },
    {
      'question': 'Air bilasan filter sebaiknya dibuang agar...',
      'option_a': 'Tidak bercampur dengan hasil seduhan',
      'option_b': 'Kopi menjadi lebih pahit',
      'option_c': 'Dosis meningkat',
      'option_d': 'Filter menjadi kering',
      'correct_answer': 'A',
    },
    {
      'question': 'Resep seduh yang repeatable memiliki...',
      'option_a': 'Parameter dosis, air, waktu, dan gilingan yang jelas',
      'option_b': 'Takaran yang selalu berubah',
      'option_c': 'Air tanpa ukuran',
      'option_d': 'Biji tanpa tanggal roasting',
      'correct_answer': 'A',
    },
  ];

  Future<List<Map<String, dynamic>>> getQuestions({int limit = 10}) async {
    if (kIsWeb) {
      final questions =
          _seedQuestions
              .map((question) => Map<String, dynamic>.from(question))
              .toList()
            ..shuffle();
      return questions.take(limit).toList();
    }

    final db = await _getDatabase();
    final countResult = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    final questionCount = Sqflite.firstIntValue(countResult) ?? 0;

    if (questionCount < _seedQuestions.length) {
      await db.transaction((transaction) async {
        await transaction.delete(_tableName);
        final batch = transaction.batch();
        for (final question in _seedQuestions) {
          batch.insert(_tableName, question);
        }
        await batch.commit(noResult: true);
      });
    }

    return db.query(_tableName, orderBy: 'RANDOM()', limit: limit);
  }

  Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = join(await getDatabasesPath(), _databaseName);
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT NOT NULL,
            option_a TEXT NOT NULL,
            option_b TEXT NOT NULL,
            option_c TEXT NOT NULL,
            option_d TEXT NOT NULL,
            correct_answer TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }
}
