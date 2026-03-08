'use client';

import { motion } from 'framer-motion';
import { TextLoop } from '@/components/ui/text-loop';

const taglines = [
    "Your Vibe. Your Rules.", // English
    "तुम्हारी वाइब। तुम्हारे नियम।", // Hindi
    "तुझी वाईब. तुझे नियम.", // Marathi
    "তোমার ভাইব। তোমার নিয়ম।", // Bengali
    "నీ వైబ్. నీ రూల్స్.", // Telugu
    "உன் வைப். உன் விதிகள்.", // Tamil
    "તારી વાઈબ. તારા નિયમો.", // Gujarati
    "آپ کی وائب۔ آپ کے قواعد۔", // Urdu
    "ನಿನ್ನ ವೈಬ್. ನಿನ್ನ ನಿಯಮಗಳು.", // Kannada
    "ତୁମର ଭାଇବ୍। ତୁମର ନିୟମ।", // Odia
    "നിന്റെ വൈബ്. നിന്റെ നിയമങ്ങൾ.", // Malayalam
    "ਤੇਰੀ ਵਾਈਬ। ਤੇਰੇ ਨਿਯਮ।", // Punjabi
    "তোমাৰ ভাইব। তোমাৰ নিয়ম।", // Assamese
    "तव भावः। तव नियमाः।" // Sanskrit
];

const auramikaTitles = [
    "Auramika Daily", // English
    "औरमिका डेली", // Hindi
    "औरमिका डेली", // Marathi
    "অরামিকা ডেইলি", // Bengali
    "ఔరమిక డైలీ", // Telugu
    "ஔரமிகா டெய்லி", // Tamil
    "ઔરમிகா ડેઇલી", // Gujarati
    "اورامیکا ڈیلی", // Urdu
    "ಔರಮಿಕಾ ಡೈಲಿ", // Kannada
    "ଔରାମିକା ଡେଲି", // Odia
    "ഔരമിക ഡെയിലി", // Malayalam
    "ਔਰਮਿਕਾ ਡੇਲੀ", // Punjabi
    "অৰামিকা ডেইলী", // Assamese
    "औरमिका डेली" // Sanskrit
];

export default function Hero() {
    return (
        <section className="relative w-full h-[100vh] bg-brand-dark overflow-hidden flex items-center justify-center">

            {/* Static fallback image — always visible until video loads */}
            <div className="absolute inset-0 z-0">
                <img
                    src="/hero_first_frame.png"
                    alt="Auramika Daily"
                    className="w-full h-full object-cover opacity-70"
                />
            </div>

            {/* Video overlaid on top of fallback */}
            <video
                autoPlay
                loop
                muted
                playsInline
                poster="/hero_first_frame.png"
                className="absolute inset-0 w-full h-full object-cover opacity-70 z-[1]"
                onError={(e) => {
                    // Hide video on error — static poster image shows through underneath
                    (e.target as HTMLVideoElement).style.display = 'none';
                }}
            >
                <source src="/download.mp4" type="video/mp4" />
                <source src="/AURAMIKLY.mp4" type="video/mp4" />
            </video>

            <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 1.5, ease: "easeOut", delay: 0.5 }}
                className="relative z-10 flex flex-col justify-center items-center px-6 text-center mt-20 w-full"
            >
                <div className="h-[70px] sm:h-[80px] md:h-[120px] lg:h-[140px] flex items-center justify-center w-full mb-3 md:mb-4 px-4">
                    <TextLoop interval={2} transition={{ duration: 0.4 }}>
                        {auramikaTitles.map((text) => (
                            <h1 key={text} className="font-playfair text-4xl sm:text-5xl md:text-7xl lg:text-8xl text-brand-light font-semibold tracking-widest uppercase block text-center leading-tight drop-shadow-[0_4px_16px_rgba(0,0,0,0.8)]">
                                {text}
                            </h1>
                        ))}
                    </TextLoop>
                </div>

                <div className="h-12 sm:h-16 md:h-20 flex items-center justify-center w-full mb-6 md:mb-8 px-4">
                    <TextLoop interval={2} transition={{ duration: 0.4 }}>
                        {taglines.map((text) => (
                            <span
                                key={text}
                                className="font-outfit text-base sm:text-xl md:text-3xl lg:text-4xl text-[#D8B4FE] tracking-widest font-medium text-center drop-shadow-[0_4px_12px_rgba(0,0,0,0.8)]"
                            >
                                {text}
                            </span>
                        ))}
                    </TextLoop>
                </div>

                <motion.p
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 1.5, delay: 1 }}
                    className="font-outfit text-sm md:text-base text-brand-light/90 max-w-lg tracking-[0.2em] uppercase leading-relaxed drop-shadow-lg font-medium"
                >
                    From the streets to the main stage. <br className="hidden md:block" /> <span className="text-[#D8B4FE] font-bold drop-shadow-[0_2px_8px_rgba(0,0,0,0.8)]">Premium imitation jewelry for all.</span> Unbeatable prices.
                </motion.p>
            </motion.div>
        </section>
    );
}
