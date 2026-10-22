import 'recipe_model.dart';

const builtInRecipes = [
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
  ),
];
