import 'recipe_model.dart';

const builtInRecipes = [
  // ─── Resep Bawaan Lama ────────────────────────────────────────────
  Recipe(
    title: 'V60 Manual Brew',
    category: 'Manual Brew',
    ingredients: '''15g Biji kopi (giling medium)
225ml Air panas (suhu 90-93°C)
1 lembar Kertas filter V60''',
    instructions:
        '''1. Letakkan kertas filter pada dripper V60, bilas dengan air panas, lalu buang air bilasan.
2. Masukkan bubuk kopi ke dalam filter, ratakan permukaannya.
3. Tuang 30ml air perlahan (proses blooming), tunggu sekitar 30 detik.
4. Tuang sisa air secara melingkar dan perlahan hingga mencapai total 225ml.
5. Tunggu hingga semua air turun (waktu ideal sekitar 2.5 menit). Angkat dripper dan sajikan.''',
    duration: 5,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/v60_manual_brew.jpeg',
  ),
  Recipe(
    title: 'Caramel Macchiato',
    category: 'Espresso Based',
    ingredients: '''1 shot Espresso (30ml)
150ml Susu Segar (Fresh Milk)
15ml Sirup Vanilla
10ml Saus Karamel (Caramel Sauce)
Es batu secukupnya (jika disajikan dingin)''',
    instructions: '''1. Tuangkan sirup vanilla ke dasar gelas.
2. (Opsional untuk dingin) Masukkan es batu hingga gelas hampir penuh.
3. Tuangkan susu segar ke dalam gelas, lalu aduk perlahan dengan sirup vanilla.
4. Tuangkan tembakan espresso tepat di tengah agar membentuk gradasi (macchiato/bercak).
5. Hias bagian atas minuman dengan pola silang menggunakan saus karamel.''',
    duration: 5,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/caramel_macchiato.jpg',
  ),
  Recipe(
    title: 'Classic Cold Brew',
    category: 'Cold Brew',
    ingredients: '''50g Biji kopi (giling kasar / coarse)
500ml Air mineral bersuhu ruang''',
    instructions:
        '''1. Masukkan bubuk kopi ke dalam wadah tertutup (mason jar atau botol kaca).
2. Tuangkan air secara perlahan, aduk rata agar semua bubuk kopi basah sempurna.
3. Tutup rapat wadah dan simpan di dalam kulkas selama 12 hingga 24 jam.
4. Keluarkan dari kulkas, lalu saring ampas kopi menggunakan kertas saring atau saringan kain bersih.
5. Sajikan dingin (bisa ditambahkan es batu atau sedikit susu/krim cair sesuai selera).''',
    duration: 720,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/classic_cold_brew.jpg',
  ),
  Recipe(
    title: 'Espresso Tonic',
    category: 'Mocktail / Coffee Soda',
    ingredients: '''1 shot Espresso (30ml), sebaiknya kopi dengan fruity notes
120ml Air Tonik (Tonic Water) dingin
1 iris Lemon atau Jeruk Nipis (untuk garnish)
Es batu secukupnya''',
    instructions:
        '''1. Siapkan gelas berukuran sedang, isi dengan es batu hingga penuh.
2. Tuangkan air tonik dingin perlahan ke dalam gelas (hindari menuang terlalu cepat agar sodanya tidak meluap).
3. Ekstrak 1 shot espresso dan segera tuangkan secara perlahan ke atas air tonik.
4. Tambahkan irisan lemon atau jeruk nipis di pinggir atau di dalam gelas.
5. Minuman siap disajikan (aduk rata sebelum diminum agar rasanya seimbang).''',
    duration: 5,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/espresso_tonic.jpg',
  ),

  // ─── 8 Resep Baru ────────────────────────────────────────────────
  Recipe(
    title: 'French Press',
    category: 'Manual Brew',
    ingredients: '''18g Biji kopi (giling kasar / coarse)
300ml Air panas (suhu 92-96°C)
1 unit French Press''',
    instructions:
        '''1. Panaskan French Press dengan menuangkan air panas, lalu buang air bilasannya.
2. Masukkan bubuk kopi ke dalam French Press.
3. Tuangkan air panas secara merata, pastikan seluruh bubuk kopi terendam.
4. Aduk perlahan selama 5 detik dengan sendok kayu, lalu tutup dengan plunger tanpa ditekan.
5. Diamkan selama 4 menit (waktu ideal untuk ekstraksi penuh).
6. Tekan plunger ke bawah secara perlahan dan stabil.
7. Segera tuang kopi ke dalam cangkir agar tidak over-extracted. Sajikan.''',
    duration: 6,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/french_press.jpg',
  ),
  Recipe(
    title: 'AeroPress',
    category: 'Manual Brew',
    ingredients: '''15g Biji kopi (giling medium-fine)
200ml Air panas (suhu 80-85°C)
1 lembar Kertas filter AeroPress
1 unit AeroPress''',
    instructions:
        '''1. Pasang kertas filter pada cap AeroPress, bilas dengan air panas untuk menghilangkan rasa kertas.
2. Pasang AeroPress pada cangkir dalam posisi standar (cap di bawah).
3. Masukkan bubuk kopi, lalu tuang 50ml air panas dan aduk selama 10 detik (blooming).
4. Tunggu 30 detik, lalu tambahkan sisa air panas hingga total 200ml.
5. Pasang plunger di atas dan diamkan selama 1 menit.
6. Tekan plunger ke bawah secara perlahan selama 20-30 detik hingga terdengar suara mendesis.
7. Sajikan langsung atau encerkan dengan air panas sesuai selera.''',
    duration: 4,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/aeropress.jpg',
  ),
  Recipe(
    title: 'Cappuccino',
    category: 'Espresso Based',
    ingredients: '''1 shot Espresso (30ml)
120ml Susu Segar (Fresh Milk)''',
    instructions:
        '''1. Ekstrak 1 shot espresso ke dalam cangkir cappuccino yang sudah dipanaskan.
2. Steam susu segar menggunakan steam wand hingga menghasilkan microfoam yang lembut dan creamy (suhu ideal 60-65°C).
3. Ketuk pitcher ke meja untuk menghilangkan gelembung besar, lalu putar perlahan agar foam menyatu.
4. Tuang susu dari ketinggian rendah ke dalam espresso, lalu angkat pitcher untuk membuat lapisan foam tebal di atas.
5. Rasio ideal: 1/3 espresso, 1/3 steamed milk, 1/3 foam. Sajikan segera.''',
    duration: 4,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/cappuccino.jpg',
  ),
  Recipe(
    title: 'Flat White',
    category: 'Espresso Based',
    ingredients: '''2 shot Espresso / 1 double shot Ristretto (60ml)
150ml Susu Segar (Fresh Milk)''',
    instructions:
        '''1. Ekstrak double shot espresso (atau ristretto) ke dalam cangkir berukuran 150-180ml.
2. Steam susu segar hingga menghasilkan microfoam yang sangat halus (tekstur seperti cat basah), dengan suhu ideal 55-62°C.
3. Ketuk pitcher dan putar perlahan agar tekstur susu glossy dan tanpa gelembung.
4. Tuang susu ke dalam espresso dari ketinggian rendah secara perlahan dan konsisten.
5. Flat white memiliki lapisan foam yang sangat tipis (sekitar 0.5cm). Sajikan segera selagi panas.''',
    duration: 4,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/flat_white.png',
  ),
  Recipe(
    title: 'Americano',
    category: 'Espresso Based',
    ingredients: '''1-2 shot Espresso (30-60ml)
120ml Air panas (suhu 85-90°C)
Es batu secukupnya (untuk versi iced)''',
    instructions: '''1. Ekstrak espresso langsung ke dalam cangkir atau gelas.
2. Untuk Hot Americano: Tuang air panas ke dalam cangkir berisi espresso. Rasio standar 1:2 (espresso:air), sesuaikan dengan selera.
3. Untuk Iced Americano: Isi gelas dengan es batu, tuang air dingin, lalu tambahkan shot espresso di atas.
4. Aduk perlahan jika diinginkan. Americano menghadirkan rasa espresso yang lebih ringan namun tetap kaya aroma.
5. Sajikan tanpa tambahan apapun untuk menikmati karakter kopi yang murni.''',
    duration: 3,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/americano.jpeg',
  ),
  Recipe(
    title: 'Café Mocha',
    category: 'Espresso Based',
    ingredients: '''1 shot Espresso (30ml)
150ml Susu Segar (Fresh Milk)
20ml Saus Cokelat (Chocolate Sauce)
Whipped Cream secukupnya (opsional)
Bubuk cokelat untuk taburan (opsional)''',
    instructions: '''1. Tuangkan saus cokelat ke dasar cangkir atau gelas.
2. Ekstrak 1 shot espresso langsung ke atas saus cokelat, aduk hingga cokelat larut sempurna.
3. Steam susu segar hingga hangat dan sedikit berbusa (suhu 60-65°C).
4. Tuang steamed milk ke dalam campuran espresso-cokelat secara perlahan.
5. (Opsional) Tambahkan whipped cream di atas dan taburi dengan bubuk cokelat atau cocoa powder.
6. Untuk versi dingin, ganti steamed milk dengan susu dingin dan tambahkan es batu.''',
    duration: 5,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/Cafe Mocha.png',
  ),
  Recipe(
    title: 'Affogato',
    category: 'Espresso Based',
    ingredients: '''1 shot Espresso panas (30ml)
1 scoop Es krim vanilla (sekitar 60g)
Biscotti atau wafer (opsional, sebagai pendamping)''',
    instructions: '''1. Siapkan cangkir atau mangkuk kecil tahan panas.
2. Letakkan 1 scoop es krim vanilla ke dalam cangkir.
3. Ekstrak 1 shot espresso yang baru dibuat dan masih panas.
4. Segera tuang espresso panas langsung ke atas es krim vanilla.
5. Sajikan segera sebelum es krim meleleh sepenuhnya — nikmati kontras antara espresso pahit yang panas dan es krim manis yang dingin.
6. (Opsional) Tambahkan biscotti di samping untuk dicelupkan.''',
    duration: 3,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/affogato.jpg',
  ),
  Recipe(
    title: 'Japanese Iced Coffee',
    category: 'Manual Brew',
    ingredients: '''20g Biji kopi (giling medium)
150ml Air panas (suhu 92-96°C)
100g Es batu (ditempatkan di server/carafe)
1 lembar Kertas filter V60 atau Kalita''',
    instructions:
        '''1. Timbang es batu dan letakkan langsung ke dalam server atau carafe penampung.
2. Pasang dripper di atas server, letakkan kertas filter, lalu bilas filter dengan sedikit air panas.
3. Masukkan bubuk kopi ke dalam filter, ratakan permukaannya.
4. Tuang 40ml air panas untuk proses blooming, tunggu 30-45 detik.
5. Lanjutkan menuang sisa air secara perlahan dan melingkar hingga total 150ml.
6. Kopi panas akan langsung menetes ke atas es batu dan mendingin secara instan (flash chilling), mengunci aroma dan rasa.
7. Aduk server perlahan agar es mencair merata, lalu tuang ke gelas berisi es batu segar. Sajikan.''',
    duration: 5,
    source: 'Resep Utama',
    imageUrl: 'assets/images/recipes/japanese_iced_coffee.jpg',
  ),
];
