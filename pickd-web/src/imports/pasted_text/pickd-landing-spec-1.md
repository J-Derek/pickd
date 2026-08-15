 Pickd Landing Page — Approved Section Specification (Do Not Modify)                                                                    
                                                                                                                                          
  ## 1. File/Component Map                                                                                                                
                                                                                                                                          
  Components listed in render hierarchy order.                                                                                            
                                                                                                                                          
  • src/App.tsx (Entry point for the layout)                                                                                              
      • src/components/Navbar.tsx (Top Navigation)                                                                                        
          • src/components/GlassButton.tsx (Download CTA component)                                                                       
      • src/components/Hero.tsx (Hero Section)                                                                                            
          • src/components/TrendingMarquee.tsx (Cinematic background poster grid, rendered with variant="hero")                           
      • src/components/ProblemStatement.tsx ("Sounds familiar?" narrative section)                                                        
                                                                                                                                          
                                                                                                                                          
  ## 2. Structure & DOM Hierarchy                                                                                                         
                                                                                                                                          
  • div (containerRef, min-h-screen bg-ink text-foreground relative) — Main App Wrapper                                                   
      • div (Interactive Background Spotlight containers tracking mouse)                                                                  
      • nav (fixed top-0 left-0 right-0 z-50 h-16)                                                                                        
          • a (Logo link) > img + span                                                                                                    
          • div (Nav Links container) > 3x a (Text links) + 1x a (GitHub icon) + GlassButton (Download)                                   
      • main (relative z-10)                                                                                                              
          • ErrorBoundary                                                                                                                 
              • div (Hero wrapper, min-h-screen pt-24 pb-16 overflow-hidden)                                                              
                  • TrendingMarquee (absolute inset-0 z-0 overflow-hidden wrapper)                                                        
                      • div (3x Environmental Lighting radial blobs)                                                                      
                      • div (3x Depth Masks for vignette/fade)                                                                            
                      • div (Marquee Grid wrapper, -rotate-[8deg] scale-110)                                                              
                          • 3x div (Row wrappers mapping to far bg, mid bg, and foreground)                                               
                                                                                                                                          
                  • motion.div (Hero Foreground Content, relative z-10 max-w-5xl text-center)                                             
                      • motion.div (Badge)                                                                                                
                      • motion.h1 (Headline)                                                                                              
                      • motion.p (Subhead)                                                                                                
                      • motion.div (CTA row) > 2x a (Download APK + See how it works)                                                     
                  • motion.div (Scroll nudge handoff indicator, absolute bottom-0)                                                        
              • section (ProblemStatement wrapper, relative w-full h-[300vh] bg-ink)                                                      
                  • div (sticky top-0 w-full h-screen overflow-hidden)                                                                    
                      • motion.div (Cold Ambient Lighting, mix-blend-screen)                                                              
                      • motion.div (Dense Poster Ecosystem, -rotate-12) > 5x motion.div (Marquee rows)                                    
                      • div (2x Depth Masks)                                                                                              
                      • div (Narrative Typography container, z-30 pointer-events-none)                                                    
                          • motion.div (Absolute centering wrapper)                                                                       
                              • 8x motion.h2 (Fading narrative lines)                                                                     
                                                                                                                                          
                                                                                                                                          
                                                                                                                                          
                                                                                                                                          
                                                                                                                                          
                                                                                                                                          
                                                                                                                                          
                                                                                                                                          
  ## 3. Styling Tokens Used (Actual Code Values)                                                                                          
                                                                                                                                          
  Colors & Backgrounds                                                                                                                    
                                                                                                                                          
  • Backgrounds: --ink (#0A0A0F), translucent Nav (rgba(10, 10, 15, 0.7)).                                                                
  • Text: text-white, text-white/90, text-white/50, text-white/40.                                                                        
  • Accents:                                                                                                                              
      • Indigo: #6B4EFF (Logo shadow, badge pulse, CTA hover effects, ambient lighting blobs).                                            
      • Cyan: #00F0FF (Ambient lighting blobs, trending marquee star icons).                                                              
      • Gold: #FFC107 (Hero marquee center light blob).                                                                                   
                                                                                                                                          
                                                                                                                                          
  Typography                                                                                                                              
                                                                                                                                          
  • Display (var(--font-display) - Sora): Logo, Hero Headline, Problem Statement Narrative.                                               
      • Weights: font-bold, font-medium, font-semibold.                                                                                   
      • Sizing (Hero): text-[4rem] to lg:text-[9rem], leading-[0.95], tracking-tighter.                                                   
      • Sizing (Narrative): text-4xl to lg:text-[7rem].                                                                                   
  • Body (var(--font-body) - Inter fallback): Badge, Hero Subhead.                                                                        
      • Badge: text-xs font-semibold uppercase tracking-widest.                                                                           
      • Subhead: text-lg md:text-xl lg:text-2xl font-medium leading-relaxed.                                                              
                                                                                                                                          
                                                                                                                                          
  Spacing, Radii & Shadows                                                                                                                
                                                                                                                                          
  • Nav: h-16, px-6 md:px-10.                                                                                                             
  • Radii: rounded-lg (Logo), rounded-full (Badge, CTA, light blobs), rounded-xl / rounded-2xl / rounded-3xl (Posters).                   
  • Shadows:                                                                                                                              
      • Logo: shadow-[0_0_10px_rgba(107,78,255,0.3)]                                                                                      
      • Hero Headline: textShadow: "0 20px 40px rgba(0,0,0,0.5)"                                                                          
      • Hero Download CTA: boxShadow: "0 10px 30px -10px rgba(107,78,255,0.3), inset 0 1px 0 0 rgba(255,255,255,0.1)"                     
      • Posters scale from shadow-lg to shadow-[0_30px_60px_rgba(0,0,0,0.6)] based on depth.                                              
                                                                                                                                          
                                                                                                                                          
  ## 4. Nav + Logo Specifics                                                                                                              
                                                                                                                                          
  • Positioning: fixed top-0 left-0 right-0 z-50. Does not change state on scroll (constant style).                                       
  • Visuals: background: rgba(10, 10, 15, 0.7) with backdrop-filter: blur(20px) and a subtle 1px solid rgba(255,255,255,0.06) bottom      
  border.                                                                                                                                 
  • Logo: img pulling from /logo.jpg, w-8 h-8 rounded-lg object-cover, paired with text "Pickd".                                          
  • Mobile Behavior: Links for "How it works", "Features", and "Report a bug" are hidden on mobile (hidden md:block). The GitHub icon and 
  Download APK button remain visible.                                                                                                     
                                                                                                                                          
  ## 5. Motion Details                                                                                                                    
                                                                                                                                          
  Global / App-level                                                                                                                      
                                                                                                                                          
  • Interactive Spotlight (App.tsx): Mouse position tracked via requestAnimationFrame setting --mouse-x and --mouse-y for a radial-       
  gradient mask and a deep indigo ambient glow.                                                                                           
                                                                                                                                          
  Hero Section (Hero.tsx)                                                                                                                 
                                                                                                                                          
  • Mount Animation (Framer Motion variants):                                                                                             
      • staggerChildren: 0.15.                                                                                                            
      • Elements (Badge, Headline, Subhead, CTA) fade in and rise (y: 16 or 24 to 0, blur(4px)/(8px) to blur(0px)).                       
      • Uses type: "spring", bounce: 0, damping: 20/25 with durations between 0.8s and 1.2s.                                              
  • Scroll Parallax (Linked to Container scrollYProgress):                                                                                
      • Content shifts down: useTransform(scrollYProgress, [0, 1], ["0%", "50%"]).                                                        
      • Content fades out: useTransform(scrollYProgress, [0, 0.6], [1, 0]).                                                               
                                                                                                                                          
                                                                                                                                          
  Hero Background Posters (TrendingMarquee.tsx variant="hero")                                                                            
                                                                                                                                          
  • Infinite Auto-Scroll: 3 rows of posters moving linearly via animate={{ x: [...] }}.                                                   
      • Row 0 (far): -50% to 0%, duration 90s.                                                                                            
      • Row 1 (mid): 0% to -50%, duration 60s.                                                                                            
      • Row 2 (fore): -50% to 0%, duration 45s.                                                                                           
  • Scroll Parallax: Wrapper moves y: [0, 1] to ["0%", "15%"] and opacity fades [0, 0.8] to [1, 0].                                       
                                                                                                                                          
  Sounds Familiar? Section (ProblemStatement.tsx)                                                                                         
                                                                                                                                          
  • Container Timeline: 300vh tall wrapper, tracking scrollYProgress (offset: ["start start", "end end"]).                                
  • Narrative Typography: Precise opacity crossfades mapped via useTransform(progress, [...], [0, 1, 1, 0]) overlapping slightly at       
  intervals (e.g., [0.0, 0.05, 0.12, 0.15] then [0.15, 0.2, 0.25, 0.28], ending with "Sound familiar?" fading out at 1.0).                
  • Atmosphere Shift:                                                                                                                     
      • Ambient light glow fades out by 0.6 to 0.                                                                                         
      • Poster opacity peaks at 0.8 (scroll progress 0.8) and falls to 0 by 1.0 (blackness).                                              
      • Blur amount changes dynamically: ["blur(12px)", "blur(3px)", "blur(12px)", "blur(40px)"] mapped to [0, 0.4, 0.9, 1.0].            
      • Scale shifts 1.1 -> 1 -> 1.3.                                                                                                     
  • Parallax Poster Scrolling: Driven by marqueeProgress (useSpring(scrollYProgress) with damping: 40, stiffness: 200 for smooth          
  deceleration). 5 rows translate horizontally mapping [0, 1] to translations like ["0%", "-40%"] and ["-40%", "0%"].                     
                                                                                                                                          
  Note: All infinite scrolling and parallax effects bypass/disable when useReducedMotion is true.                                         
                                                                                                                                          
  ## 6. Assets                                                                                                                            
                                                                                                                                          
  • /logo.jpg (Public folder) — Used exclusively in Navbar.tsx.                                                                           
  • TMDB API Poster Image URLs — Sourced via useTrendingMovies() hook and mapped dynamically in TrendingMarquee.tsx and ProblemStatement. 
  tsx.                                                                                                                                    
                                                                                                                                          
  ## 7. Responsive Differences                                                                                                            
                                                                                                                                          
  • Nav: Text links collapse to hidden md:block.                                                                                          
  • Hero Typography:                                                                                                                      
      • Headline steps from text-[4rem] to sm:text-7xl to md:text-8xl to lg:text-[9rem].                                                  
      • Subhead steps from text-lg to md:text-xl to lg:text-2xl.                                                                          
  • Hero Layout: CTA buttons stack on mobile (flex-col) and align horizontally on tablet (sm:flex-row).                                   
  • Background Ecosystems (TrendingMarquee & ProblemStatement):                                                                           
      • Poster widths/heights use md: scaling extensively (e.g., w-24 md:w-36, h-36 md:h-52).                                             
      • Gaps scale up (e.g., gap-4 md:gap-6).                                                                                             
  • Problem Statement Narrative: Font sizes scale dramatically across breakpoints to maintain impact (e.g., text-4xl md:text-6xl lg:text- 
  [5rem]).   