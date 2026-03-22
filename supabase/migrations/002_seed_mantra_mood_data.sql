-- ============================================================
-- Migration 002: Seed Mantra & Mood-Mantra Mapping Data
-- Run in Supabase SQL Editor after migration 001
-- ============================================================
--
-- DATA SUMMARY:
--   25 unique mantras
--   30 mood-mantra mappings (6 mantras per mood)
--   Moods covered: Awesome, Good, Neutral, Bad, Terrible
--   Note: 'Other' mood has no mappings yet
--
-- ============================================================
-- AUDIO FILE CHECKLIST — upload all files to Supabase Storage
-- bucket: mantra-audio (create as Public)
--
-- FILES YOU ALREADY HAVE (rename and upload):
--   asato_ma.mp3                <- "Asato Ma Sad Gamaya Tamaso Ma Jyotir Gamaya.mp3"
--   gayatri_mantra.mp3          <- "Om Bhur Bhuva Swaha...Mira Audios[music+vocals].mp3"
--   om_namo_narayanaya.mp3      <- "Om Namo Narayanaya...Short.mp3"
--   om_sarve_bhavantu.mp3       <- "Om Sarve Bhavantu Sukhinah.mp3"
--   om_shanti_shanti.mp3        <- "Om Shanti Shanti Shanti.mp3"
--
-- FILES ON YOUR GOOGLE DRIVE (download → rename → upload):
--   hare_rama_hare_rama.mp3     <- drive.google.com/file/d/1gbBeBLv7WHNkKt-FKmJTcvJrEg7xJp6d
--   lokah_samastah.mp3          <- drive.google.com/file/d/1MPoWj0GBq_4jElLzJ7KxvGhSklKi5qdq
--   om_gam_ganapataye.mp3       <- drive.google.com/file/d/1vjHem1URO7kPBPxCLIcaLUkzPSuUNJC7
--   om_kraam_bhaumaya.mp3       <- drive.google.com/file/d/1WI0lDCUvmQQIqYR1b1NEY8pfmv0P8oGl
--   om_namah_shivaya.mp3        <- drive.google.com/file/d/1qnFp4pZcqL4BgLbQCiYK9Jai9hfPrbSd
--   om_purnam.mp3               <- drive.google.com/file/d/1jdmqIDHujh2NqhueN0wuapluIqPIt6Y3
--   om_shri_ganeshaya.mp3       <- drive.google.com/file/d/1Tyo3_t0zINYqzo_B5AjC9uIpdEsiLRlX
--   om_shri_maha_lakshmyai.mp3  <- drive.google.com/file/d/1kHvrUvH2jJP7rZBy71dUVyMiujpOhoZd
--   sarvesham_svastir.mp3       <- drive.google.com/file/d/1kMeHfkyW-s_HD8SoQ_H_uVu85K7uv9MD
--   mahamrityunjaya.mp3         <- drive.google.com/file/d/1ajLlNplfemvJfU_tD6eeW9Bq6fyktv1N
--
-- AUDIO STILL NEEDED (search Pixabay/Freesound for royalty-free versions):
--   hare_krishna_hare_rama.mp3
--   om_aum.mp3
--   om_aim_hreem_chamundayai.mp3
--   om_dum_durgayai.mp3
--   om_hanumate.mp3
--   om_namo_bhagavate.mp3
--   om_shreem_mahalakshmyai.mp3
--   om_shri_ramaya.mp3
--   om_tat_sat.mp3
--   so_hum.mp3
-- ============================================================

-- ============================================================
-- STEP 1: Update mantra_moods to store mood-specific content
-- (meaning framing and objective vary per mood for same mantra)
-- ============================================================
ALTER TABLE mantra_moods ADD COLUMN IF NOT EXISTS mood_specific_meaning text;
ALTER TABLE mantra_moods ADD COLUMN IF NOT EXISTS objective             text;


-- ============================================================
-- STEP 2: Insert 25 unique mantras
-- audio_url uses Supabase Storage pattern — update after upload
-- ============================================================

INSERT INTO mantras (title, sanskrit_name, transliteration, meaning, deity, duration_seconds, audio_url, icon_name, icon_color_hex)
VALUES

  -- 1
  ('Asato Ma',
   'असतो मा सद्गमय तमसो मा ज्योतिर्गमय',
   'Asato Ma Sad Gamaya Tamaso Ma Jyotir Gamaya',
   'Lead me from untruth to truth, darkness to light.',
   'Universal/Vedic', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/asato_ma.mp3',
   'wb_sunny', '#FFF8E1'),

  -- 2
  ('Hare Krishna Hare Rama',
   'हरे कृष्ण हरे राम',
   'Hare Krishna Hare Rama',
   'Invocation of Krishna and Rama.',
   'Lord Krishna & Rama', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/hare_krishna_hare_rama.mp3',
   'music_note', '#E8F5E9'),

  -- 3
  ('Hare Rama Hare Rama',
   'हरे राम हरे राम राम राम हरे हरे',
   'Hare Rama Hare Rama Rama Rama Hare Hare',
   'Invocation of Lord Rama with joyful energy.',
   'Lord Rama', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/hare_rama_hare_rama.mp3',
   'celebration', '#FFF3E0'),

  -- 4
  ('Lokah Samastah',
   'लोकाः समस्ताः सुखिनो भवन्तु',
   'Lokah Samastah Sukhino Bhavantu',
   'May all beings everywhere be happy and free.',
   'Universal/Non-specific', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/lokah_samastah.mp3',
   'favorite', '#FCE4EC'),

  -- 5
  ('Om Aum',
   'ॐ',
   'Om / Aum',
   'The primordial sound of the universe.',
   'Universal/Brahman', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_aum.mp3',
   'self_improvement', '#EDE7F6'),

  -- 6
  ('Om Aim Hreem Chamundayai',
   'ॐ ऐं ह्रीं क्लीं चामुण्डायै विच्चे',
   'Om Aim Hreem Kleem Chamundayai Vichche',
   'Salutations to Goddess Chamunda.',
   'Goddess Chamunda', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_aim_hreem_chamundayai.mp3',
   'auto_awesome', '#F3E5F5'),

  -- 7
  ('Gayatri Mantra',
   'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि धियो यो नः प्रचोदयात्',
   'Om Bhur Bhuvah Svah Tat Savitur Varenyam Bhargo Devasya Dhimahi Dhiyo Yo Nah Prachodayat',
   'We meditate on the divine light of the Sun.',
   'Sun God (Savitri)', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/gayatri_mantra.mp3',
   'light_mode', '#FFFDE7'),

  -- 8
  ('Om Dum Durgayai',
   'ॐ दुं दुर्गायै नमः',
   'Om Dum Durgayai Namaha',
   'Salutations to Goddess Durga.',
   'Goddess Durga', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_dum_durgayai.mp3',
   'shield', '#FFEBEE'),

  -- 9
  ('Om Gam Ganapataye',
   'ॐ गं गणपतये नमः',
   'Om Gam Ganapataye Namaha',
   'Salutations to Lord Ganesha, the remover of obstacles.',
   'Lord Ganesha', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_gam_ganapataye.mp3',
   'emoji_events', '#FFF3E0'),

  -- 10
  ('Om Hanumate',
   'ॐ हनुमते नमः',
   'Om Hanumate Namaha',
   'Salutations to Hanuman.',
   'Lord Hanuman', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_hanumate.mp3',
   'fitness_center', '#FBE9E7'),

  -- 11
  ('Om Kraam Bhaumaya',
   'ॐ क्रां क्रीं क्रौं सः भौमाय नमः',
   'Om Kraam Kreem Kraum Sah Bhaumaya Namaha',
   'Salutations to planet Mars (Mangal).',
   'Mars/Mangal', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_kraam_bhaumaya.mp3',
   'whatshot', '#FFCCBC'),

  -- 12
  ('Om Namah Shivaya',
   'ॐ नमः शिवाय',
   'Om Namah Shivaya',
   'I bow to Shiva, the divine Self.',
   'Lord Shiva', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_namah_shivaya.mp3',
   'spa', '#E8EAF6'),

  -- 13
  ('Om Namo Bhagavate Vasudevaya',
   'ॐ नमो भगवते वासुदेवाय',
   'Om Namo Bhagavate Vasudevaya',
   'Salutations to Lord Vasudeva (Krishna).',
   'Lord Krishna/Vasudeva', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_namo_bhagavate.mp3',
   'volunteer_activism', '#E3F2FD'),

  -- 14
  ('Om Namo Narayanaya',
   'ॐ नमो नारायणाय',
   'Om Namo Narayanaya',
   'Salutations to Lord Narayana (Vishnu).',
   'Lord Vishnu/Narayana', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_namo_narayanaya.mp3',
   'star', '#E1F5FE'),

  -- 15
  ('Om Purnam',
   'ॐ पूर्णमदः पूर्णमिदं पूर्णात्पूर्णमुदच्यते पूर्णस्य पूर्णमादाय पूर्णमेवावशिष्यते ॐ शान्तिः शान्तिः शान्तिः',
   'Om Puurnnam-Adah Puurnnam-Idam Puurnnaat-Puurnnam-Udacyate Puurnnasya Puurnnam-Aadaaya Puurnnam-Eva-Avashissyate Om Shaantih Shaantih Shaantih',
   'Om, That (Outer World) is Full with Divine Consciousness; This (Inner World) is also Full. From the Full, the Full arises; Taking the Full from the Full, the Full remains. Om Peace Peace Peace.',
   'Universal/Vedic', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_purnam.mp3',
   'all_inclusive', '#E8F5E9'),

  -- 16
  ('Om Sarve Bhavantu Sukhinah',
   'ॐ सर्वे भवन्तु सुखिनः',
   'Om Sarve Bhavantu Sukhinah',
   'May all be happy, may all be free from disease.',
   'Universal/Vedic', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_sarve_bhavantu.mp3',
   'healing', '#F1F8E9'),

  -- 17
  ('Om Shanti Shanti Shanti',
   'ॐ शान्तिः शान्तिः शान्तिः',
   'Om Shanti Shanti Shanti',
   'Om Peace Peace Peace.',
   'Universal/Vedic', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_shanti_shanti.mp3',
   'nightlight_round', '#E8EAF6'),

  -- 18
  ('Om Shreem Mahalakshmyai',
   'ॐ श्रीं ह्रीं क्लीं त्रिभुवन महालक्ष्म्यै नमः',
   'Om Shreem Hreem Kleem Tribhuvan Mahalakshmyai Namaha',
   'Salutations to Goddess Mahalakshmi of three worlds.',
   'Goddess Mahalakshmi', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_shreem_mahalakshmyai.mp3',
   'monetization_on', '#FFF8E1'),

  -- 19
  ('Om Shri Ganeshaya',
   'ॐ श्री गणेशाय नमः',
   'Om Shri Ganeshaya Namaha',
   'Salutations to Lord Ganesha.',
   'Lord Ganesha', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_shri_ganeshaya.mp3',
   'emoji_events', '#FFF3E0'),

  -- 20
  ('Om Shri Maha Lakshmyai',
   'ॐ श्री महा लक्ष्म्यै नमः',
   'Om Shri Maha Lakshmyai Namaha',
   'Salutations to Goddess Lakshmi.',
   'Goddess Lakshmi', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_shri_maha_lakshmyai.mp3',
   'diamond', '#FFF8E1'),

  -- 21
  ('Om Shri Ramaya',
   'ॐ श्री रामाय नमः',
   'Om Shri Ramaya Namaha',
   'Salutations to Lord Rama.',
   'Lord Rama', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_shri_ramaya.mp3',
   'verified', '#E8F5E9'),

  -- 22
  ('Om Tat Sat',
   'ॐ तत् सत्',
   'Om Tat Sat',
   'Om, That is Truth.',
   'Universal/Brahman', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/om_tat_sat.mp3',
   'psychology', '#EDE7F6'),

  -- 23
  ('Mahamrityunjaya Mantra',
   'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय मामृतात्',
   'Om Tryambakam Yajamahe Sugandhim Pushtivardhanam Urvarukamiva Bandhanan Mrityor Mukshiya Maamritat',
   'We worship the three-eyed Lord Shiva who is fragrant and nourishes all beings. May he liberate us from the bondage of death.',
   'Lord Shiva', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/mahamrityunjaya.mp3',
   'favorite_border', '#F3E5F5'),

  -- 24
  ('Sarvesham Svastir Bhavatu',
   'सर्वेशां स्वस्तिर्भवतु',
   'Sarvesham Svastir Bhavatu',
   'May auspiciousness be unto all.',
   'Universal/Non-specific', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/sarvesham_svastir.mp3',
   'volunteer_activism', '#E8F5E9'),

  -- 25
  ('So Hum',
   'सो हम्',
   'So Hum',
   'I am That - unity with the universe.',
   'Universal/Non-specific', 0,
   'https://gijwddvwiqetsyklsimk.supabase.co/storage/v1/object/public/mantra-audio/so_hum.mp3',
   'air', '#E0F7FA');


-- ============================================================
-- STEP 3: Insert 30 mood-mantra mappings
-- mood_specific_meaning = how this mantra is framed for this mood
-- objective = what it helps the user with in this mood context
-- ============================================================

-- ─── AWESOME (6 mantras) ────────────────────────────────────

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Invocation of Lord Rama with joyful energy.',
  'Celebrates divine bliss, victory of righteousness, uplifts positive energy and joyful spirit',
  1
FROM mantras m, moods mo
WHERE m.title = 'Hare Rama Hare Rama' AND mo.name = 'Awesome';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'May all beings everywhere be happy and free.',
  'Cultivates universal compassion, celebrates collective happiness, expands gratitude beyond self',
  2
FROM mantras m, moods mo
WHERE m.title = 'Lokah Samastah' AND mo.name = 'Awesome';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Lord Ganesha, the remover of obstacles.',
  'Removes obstacles, brings success in new ventures, celebrates achievements and new beginnings',
  3
FROM mantras m, moods mo
WHERE m.title = 'Om Gam Ganapataye' AND mo.name = 'Awesome';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Lord Narayana (Vishnu).',
  'Celebrates divine grace, protection, supreme happiness, spiritual elevation and life victories',
  4
FROM mantras m, moods mo
WHERE m.title = 'Om Namo Narayanaya' AND mo.name = 'Awesome';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Lord Ganesha.',
  'Brings wisdom, removes barriers to success, celebrates auspicious moments and joyful ventures',
  5
FROM mantras m, moods mo
WHERE m.title = 'Om Shri Ganeshaya' AND mo.name = 'Awesome';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Goddess Lakshmi.',
  'Invokes abundance, prosperity, financial success, gratitude for blessings and material/spiritual wealth',
  6
FROM mantras m, moods mo
WHERE m.title = 'Om Shri Maha Lakshmyai' AND mo.name = 'Awesome';


-- ─── GOOD (6 mantras) ───────────────────────────────────────

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Lead me from untruth to truth, darkness to light.',
  'Guides towards truth, positive clarity, enlightenment, dispels confusion and brings understanding',
  1
FROM mantras m, moods mo
WHERE m.title = 'Asato Ma' AND mo.name = 'Good';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Goddess Chamunda.',
  'Positive transformation, removes negative influences, brings good fortune and protective energy',
  2
FROM mantras m, moods mo
WHERE m.title = 'Om Aim Hreem Chamundayai' AND mo.name = 'Good';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'We meditate on the divine light of the Sun.',
  'Enhances wisdom, mental clarity, spiritual illumination, positive intellect and enlightened thinking',
  3
FROM mantras m, moods mo
WHERE m.title = 'Gayatri Mantra' AND mo.name = 'Good';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'I bow to Shiva, the inner Self.',
  'Brings inner peace, balances five elements, harmonizes body-mind-spirit, positive transformation',
  4
FROM mantras m, moods mo
WHERE m.title = 'Om Namah Shivaya' AND mo.name = 'Good';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Lord Rama.',
  'Cultivates righteousness, moral courage, good character, ethical strength and positive values',
  5
FROM mantras m, moods mo
WHERE m.title = 'Om Shri Ramaya' AND mo.name = 'Good';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'May auspiciousness be unto all.',
  'Promotes well-being, spreads positive blessings, cultivates benevolent thoughts for all beings',
  6
FROM mantras m, moods mo
WHERE m.title = 'Sarvesham Svastir Bhavatu' AND mo.name = 'Good';


-- ─── NEUTRAL (6 mantras) ────────────────────────────────────

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Invocation of Krishna and Rama.',
  'Brings steadiness, emotional equanimity, balanced devotion and mental equilibrium',
  1
FROM mantras m, moods mo
WHERE m.title = 'Hare Krishna Hare Rama' AND mo.name = 'Neutral';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'The primordial sound of the universe.',
  'Centers the mind, balances energy, connects with universal consciousness and cosmic vibration',
  2
FROM mantras m, moods mo
WHERE m.title = 'Om Aum' AND mo.name = 'Neutral';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Om, That is Full; This is Full. From the Full, the Full arises. Taking the Full from the Full, the Full remains. Om Peace Peace Peace.',
  'Affirms completeness, balances perception, brings equilibrium and acceptance of wholeness',
  3
FROM mantras m, moods mo
WHERE m.title = 'Om Purnam' AND mo.name = 'Neutral';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Om Peace Peace Peace.',
  'Invokes peace in body, mind and spirit, creates calm neutral energy and inner stillness',
  4
FROM mantras m, moods mo
WHERE m.title = 'Om Shanti Shanti Shanti' AND mo.name = 'Neutral';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Om, That is Truth.',
  'Affirms ultimate reality, brings contemplative stillness, philosophical grounding and neutral awareness',
  5
FROM mantras m, moods mo
WHERE m.title = 'Om Tat Sat' AND mo.name = 'Neutral';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'I am That - unity with the universe.',
  'Natural breath awareness, centering practice, affirms oneness with existence and present moment',
  6
FROM mantras m, moods mo
WHERE m.title = 'So Hum' AND mo.name = 'Neutral';


-- ─── BAD (6 mantras) ────────────────────────────────────────

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Goddess Durga.',
  'Invokes courage, strength to overcome difficulties, protection from negativity and obstacles',
  1
FROM mantras m, moods mo
WHERE m.title = 'Om Dum Durgayai' AND mo.name = 'Bad';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Hanuman.',
  'Brings physical/mental courage, devotional strength, helps overcome fears and challenges',
  2
FROM mantras m, moods mo
WHERE m.title = 'Om Hanumate' AND mo.name = 'Bad';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to planet Mars (Mangal).',
  'Reduces anger and frustration, provides determination, courage and energy to face challenges',
  3
FROM mantras m, moods mo
WHERE m.title = 'Om Kraam Bhaumaya' AND mo.name = 'Bad';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Lord Vasudeva (Krishna).',
  'Removes negative emotions, brings inner strength, divine protection, emotional resilience',
  4
FROM mantras m, moods mo
WHERE m.title = 'Om Namo Bhagavate Vasudevaya' AND mo.name = 'Bad';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Salutations to Goddess Mahalakshmi of three worlds.',
  'Removes financial worries, scarcity mindset, restores hope, abundance and material stability',
  5
FROM mantras m, moods mo
WHERE m.title = 'Om Shreem Mahalakshmyai' AND mo.name = 'Bad';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'We worship the three-eyed one who nourishes all.',
  'Powerful healing, protection from suffering, relief from fear, overcomes health/life challenges',
  6
FROM mantras m, moods mo
WHERE m.title = 'Mahamrityunjaya Mantra' AND mo.name = 'Bad';


-- ─── TERRIBLE (6 mantras) ───────────────────────────────────

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'May all beings everywhere be happy and free.',
  'Shifts from personal suffering to universal compassion, collective healing, perspective expansion',
  1
FROM mantras m, moods mo
WHERE m.title = 'Lokah Samastah' AND mo.name = 'Terrible';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Divine illumination through supreme darkness.',
  'Invokes supreme divine light to pierce through deepest darkness, despair and hopelessness',
  2
FROM mantras m, moods mo
WHERE m.title = 'Gayatri Mantra' AND mo.name = 'Terrible';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'I bow to Shiva, the transformer.',
  'Transmutes deep pain and grief into acceptance, invokes transformation through crisis and rebirth',
  3
FROM mantras m, moods mo
WHERE m.title = 'Om Namah Shivaya' AND mo.name = 'Terrible';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'May all be happy, free from disease.',
  'Prayer for relief from intense suffering, universal well-being, hope restoration in crisis',
  4
FROM mantras m, moods mo
WHERE m.title = 'Om Sarve Bhavantu Sukhinah' AND mo.name = 'Terrible';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Om Peace Peace Peace - threefold peace.',
  'Profound peace during extreme turbulence, trauma, mental crisis and emotional devastation',
  5
FROM mantras m, moods mo
WHERE m.title = 'Om Shanti Shanti Shanti' AND mo.name = 'Terrible';

INSERT INTO mantra_moods (mantra_id, mood_id, mood_specific_meaning, objective, display_order)
SELECT m.id, mo.id,
  'Liberation from the cycle of death and suffering.',
  'Intense healing for severe distress, life crises, trauma recovery, protection in darkest moments',
  6
FROM mantras m, moods mo
WHERE m.title = 'Mahamrityunjaya Mantra' AND mo.name = 'Terrible';


-- ============================================================
-- STEP 4: Create a view for easy querying from Flutter
-- Usage: SELECT * FROM mantras_by_mood WHERE mood_name = 'Bad'
-- ============================================================
CREATE OR REPLACE VIEW mantras_by_mood AS
SELECT
  mm.mood_specific_meaning,
  mm.objective,
  mm.display_order,
  mo.name        AS mood_name,
  mo.emoji       AS mood_emoji,
  m.id           AS mantra_id,
  m.title,
  m.sanskrit_name,
  m.transliteration,
  m.meaning,
  m.deity,
  m.duration_seconds,
  m.audio_url,
  m.icon_name,
  m.icon_color_hex
FROM mantra_moods mm
JOIN moods   mo ON mo.id = mm.mood_id
JOIN mantras m  ON m.id  = mm.mantra_id
ORDER BY mo.name, mm.display_order;

-- RLS on the view (inherits from base tables, but grant explicit select)
GRANT SELECT ON mantras_by_mood TO authenticated, anon;
