import React, { useEffect, useMemo, useState } from "react";

// Simple, single-file prototype for the CampusMove app
// - Tabs: Covoiturage, Itinéraires, Emissions, Planning, Alertes
// - Mock data + localStorage persistence
// - PWA-friendly layout, mobile-first
// No external UI libs required. Tailwind classes assumed available in Canvas preview.

function Section({ title, children, right }) {
  return (
    <div className="bg-white shadow-sm rounded-2xl p-4 md:p-6 mb-5 border border-gray-100">
      <div className="flex items-start justify-between mb-3">
        <h2 className="text-xl font-semibold tracking-tight">{title}</h2>
        {right}
      </div>
      <div>{children}</div>
    </div>
  );
}

function Pill({ children, active = false, onClick }) {
  return (
    <button
      onClick={onClick}
      className={
        "px-3 py-1.5 rounded-full text-sm mr-2 mb-2 border " +
        (active
          ? "bg-emerald-600 text-white border-emerald-600"
          : "bg-white text-gray-700 border-gray-200 hover:bg-gray-50")
      }
    >
      {children}
    </button>
  );
}

function Progress({ value, max = 100 }) {
  const pct = Math.min(100, Math.round((value / max) * 100));
  return (
    <div className="w-full h-3 bg-gray-100 rounded-full overflow-hidden">
      <div
        className="h-3 bg-emerald-600"
        style={{ width: `${pct}%`, transition: "width 300ms ease" }}
      />
    </div>
  );
}

function Stat({ label, value, unit }) {
  return (
    <div className="bg-gray-50 rounded-xl p-4 flex-1 text-center">
      <div className="text-2xl font-bold">{value}{unit && <span className="text-base font-medium ml-1">{unit}</span>}</div>
      <div className="text-gray-500 text-sm mt-1">{label}</div>
    </div>
  );
}

// --- Utilities ---
const LS_KEY = "campusmove_state_v1";

function useLocalState(defaultState) {
  const [state, setState] = useState(() => {
    try {
      const raw = localStorage.getItem(LS_KEY);
      return raw ? JSON.parse(raw) : defaultState;
    } catch (e) {
      return defaultState;
    }
  });
  useEffect(() => {
    localStorage.setItem(LS_KEY, JSON.stringify(state));
  }, [state]);
  return [state, setState];
}

// --- Mock Data ---
const RESIDENCES = [
  "Centre-ville",
  "Quartier Avenir",
  "Résidence Atlas",
  "Oasis",
  "Sidi Maarouf",
];

const CAMPUS = "Campus Universitaire";

const BIKE_STATIONS = [
  { id: 1, name: "Atlas - Station V1", available: 8 },
  { id: 2, name: "Oasis - Station V2", available: 3 },
  { id: 3, name: "Campus - Station V3", available: 15 },
];

const PT_LINES = [
  { id: "B12", from: "Centre-ville", to: CAMPUS, every: 12, first: "06:30" },
  { id: "B7", from: "Oasis", to: CAMPUS, every: 10, first: "06:45" },
  { id: "T3", from: "Sidi Maarouf", to: CAMPUS, every: 8, first: "06:20" },
];

const CARBON_FACTORS = {
  walk: 0, // kg CO2e/km
  bike: 0,
  bus: 0.089, // approximate per pax-km
  carSolo: 0.192, // petrol average
  carShare: 0.07, // shared effective per pax-km
};

function kmBetween(a, b) {
  // Fake distances for demo
  const map = {
    "Centre-ville": 6.2,
    "Quartier Avenir": 4.7,
    "Résidence Atlas": 3.1,
    "Oasis": 5.4,
    "Sidi Maarouf": 7.8,
  };
  return map[a] ?? 4.5;
}

// Simple inline SVGs for visuals
function BikeSVG({ className = "w-20 h-20" }) {
  return (
    <svg viewBox="0 0 256 256" className={className} xmlns="http://www.w3.org/2000/svg">
      <circle cx="64" cy="180" r="36" fill="#10b981" opacity="0.15"/>
      <circle cx="192" cy="180" r="36" fill="#14b8a6" opacity="0.15"/>
      <path d="M92 92h24l18 36h34" stroke="#065f46" strokeWidth="10" fill="none" strokeLinecap="round"/>
      <path d="M108 128l-16 32" stroke="#065f46" strokeWidth="10" fill="none" strokeLinecap="round"/>
      <circle cx="120" cy="88" r="10" fill="#065f46"/>
    </svg>
  );
}

function CarpoolSVG({ className = "w-20 h-20" }) {
  return (
    <svg viewBox="0 0 256 256" className={className} xmlns="http://www.w3.org/2000/svg">
      <rect x="40" y="90" width="176" height="80" rx="12" fill="#10b981" opacity="0.15"/>
      <path d="M60 170h136" stroke="#065f46" strokeWidth="10"/>
      <circle cx="92" cy="170" r="12" fill="#065f46"/>
      <circle cx="164" cy="170" r="12" fill="#065f46"/>
      <path d="M70 90l26-24h64l26 24" stroke="#065f46" strokeWidth="10" fill="none"/>
    </svg>
  );
}

function HeroPromo() {
  return (
    <section className="bg-gradient-to-r from-emerald-100 to-teal-100 border border-emerald-200 rounded-2xl mx-4 mt-4 md:mt-6 p-5 md:p-8">
      <div className="flex flex-col md:flex-row items-center gap-6">
        <div className="flex-1">
          <div className="inline-flex items-center gap-2 text-emerald-700 text-xs font-semibold uppercase tracking-wider">
            <span className="w-2 h-2 rounded-full bg-emerald-600"/>
            CampusMove</div>
          <h1 className="text-2xl md:text-3xl font-bold mt-2">Ta mobilité plus simple, plus verte 🌱</h1>
          <p className="text-gray-700 mt-2">Covoiture, pédale ou prends le bus — l'app calcule le meilleur trajet et suit tes économies de CO₂. Rejoins le mouvement.</p>
          <div className="mt-4 flex flex-wrap items-center gap-2">
            <span className="px-3 py-1 rounded-full bg-white border border-emerald-200 text-emerald-800 text-sm">Jusqu'à −70% d'émissions</span>
            <span className="px-3 py-1 rounded-full bg-white border border-emerald-200 text-emerald-800 text-sm">Badges & objectifs</span>
            <span className="px-3 py-1 rounded-full bg-white border border-emerald-200 text-emerald-800 text-sm">Alertes en temps réel</span>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div className="bg-white shadow rounded-xl p-4 border border-emerald-100">
            <BikeSVG className="w-24 h-24"/>
            <div className="text-sm font-semibold mt-2">Itinéraires vélo</div>
          </div>
          <div className="bg-white shadow rounded-xl p-4 border border-emerald-100">
            <CarpoolSVG className="w-24 h-24"/>
            <div className="text-sm font-semibold mt-2">Covoiturage</div>
          </div>
        </div>
      </div>
    </section>
  );
}

// --- Core App ---
export default function CampusMoveApp() {
  // Register service worker for PWA install (expects /sw.js at site root)
  useEffect(() => {
    if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
      navigator.serviceWorker.register('/sw.js').catch(() => {});
    }
  }, []);
  const [state, setState] = useLocalState({
    user: { name: "Etudiant·e", residence: "Résidence Atlas" },
    carpoolOffers: [
      { id: 1, driver: "Imane", from: "Oasis", to: CAMPUS, time: "07:45", seats: 2, note: "Départ devant la boulangerie" },
      { id: 2, driver: "Youssef", from: "Centre-ville", to: CAMPUS, time: "08:10", seats: 3, note: "Autoroute -> porte nord" },
      { id: 3, driver: "Hassan", from: "Sidi Maarouf", to: CAMPUS, time: "08:00", seats: 1, note: "Passage par Quartier Avenir" },
    ],
    bookings: [],
    emissionsSavedKg: 0,
    schedule: [
      { day: "Lun", start: "08:30", end: "12:00" },
      { day: "Mar", start: "10:00", end: "16:00" },
      { day: "Mer", start: "09:00", end: "13:00" },
    ],
    alerts: [
      { id: "w", type: "météo", text: "Pluie prévue demain matin. Pensez au poncho vélo." },
      { id: "t", type: "trafic", text: "Ralentissement sur N11 à 8h-9h." },
      { id: "b", type: "vélos", text: "Faible disponibilité à Oasis - Station V2." },
    ],
  });

  const [tab, setTab] = useState("covoiturage");

  return (
    <div className="min-h-screen bg-gradient-to-b from-emerald-50 to-teal-50 text-gray-900">
      <header className="sticky top-0 z-10 backdrop-blur bg-white/70 border-b">
        <div className="max-w-5xl mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-2xl bg-emerald-600 text-white grid place-items-center font-bold">CM</div>
            <div>
              <div className="text-sm text-gray-500">Bienvenue</div>
              <div className="font-semibold">{state.user.name}</div>
            </div>
          </div>
          <div className="hidden md:flex items-center gap-2">
            {[
              ["covoiturage", "Covoiturage"],
              ["itineraires", "Itinéraires"],
              ["emissions", "Émissions"],
              ["planning", "Planning"],
              ["alertes", "Alertes"],
            ].map(([key, label]) => (
              <Pill key={key} active={tab === key} onClick={() => setTab(key)}>
                {label}
              </Pill>
            ))}
          </div>
        </div>
      </header>

      <HeroPromo />
      <main className="max-w-5xl mx-auto px-4 py-5">
        {/* Mobile Tabs */}
        <div className="md:hidden mb-4 flex flex-wrap">
          {[
            ["covoiturage", "Covoiturage"],
            ["itineraires", "Itinéraires"],
            ["emissions", "Émissions"],
            ["planning", "Planning"],
            ["alertes", "Alertes"],
          ].map(([key, label]) => (
            <Pill key={key} active={tab === key} onClick={() => setTab(key)}>
              {label}
            </Pill>
          ))}
        </div>

        {tab === "covoiturage" && (
          <CarpoolSection state={state} setState={setState} />
        )}
        {tab === "itineraires" && (
          <RoutesSection state={state} setState={setState} />
        )}
        {tab === "emissions" && (
          <EmissionsSection state={state} setState={setState} />
        )}
        {tab === "planning" && (
          <PlanningSection state={state} setState={setState} />
        )}
        {tab === "alertes" && (
          <AlertsSection state={state} setState={setState} />
        )}
      </main>

      <footer className="max-w-5xl mx-auto px-4 pb-8 text-center text-sm text-gray-500">
        CampusMove · Prototype · © {new Date().getFullYear()}
      </footer>
    </div>
  );
}

function CarpoolSection({ state, setState }) {
  const [from, setFrom] = useState(state.user.residence);
  const [to] = useState(CAMPUS);
  const [time, setTime] = useState("08:00");
  const [seats, setSeats] = useState(1);
  const [note, setNote] = useState("");

  const matches = useMemo(() => {
    return state.carpoolOffers.filter(
      (o) => o.from === from && o.to === to
    );
  }, [state.carpoolOffers, from, to]);

  function publishOffer() {
    const id = Math.max(0, ...state.carpoolOffers.map((o) => o.id)) + 1;
    const offer = {
      id,
      driver: state.user.name,
      from,
      to,
      time,
      seats: Number(seats),
      note,
    };
    setState({ ...state, carpoolOffers: [offer, ...state.carpoolOffers] });
  }

  function book(o) {
    if (o.seats <= 0) return;
    const updated = state.carpoolOffers.map((x) =>
      x.id === o.id ? { ...x, seats: x.seats - 1 } : x
    );
    const distance = kmBetween(o.from, o.to);
    const saved = distance * (CARBON_FACTORS.carSolo - CARBON_FACTORS.carShare);
    setState({
      ...state,
      carpoolOffers: updated,
      bookings: [{ offerId: o.id, when: new Date().toISOString() }, ...state.bookings],
      emissionsSavedKg: state.emissionsSavedKg + saved,
    });
  }

  return (
    <>
      <Section title="Trouver un trajet">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
          <div>
            <label className="text-sm text-gray-600">Départ</label>
            <select
              value={from}
              onChange={(e) => setFrom(e.target.value)}
              className="w-full mt-1 border rounded-xl p-2"
            >
              {RESIDENCES.map((r) => (
                <option key={r}>{r}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="text-sm text-gray-600">Arrivée</label>
            <input disabled value={to} className="w-full mt-1 border rounded-xl p-2 bg-gray-50" />
          </div>
          <div>
            <label className="text-sm text-gray-600">Heure</label>
            <input
              type="time"
              value={time}
              onChange={(e) => setTime(e.target.value)}
              className="w-full mt-1 border rounded-xl p-2"
            />
          </div>
          <div className="flex items-end">
            <button onClick={() => {}}
              className="w-full bg-emerald-600 text-white rounded-xl p-3">Rechercher</button>
          </div>
        </div>

        <div className="mt-4 grid gap-3">
          {matches.length === 0 && (
            <div className="text-gray-500 text-sm">Aucune offre correspondant à ces critères pour le moment.</div>
          )}
          {matches.map((o) => (
            <div key={o.id} className="border rounded-xl p-3 flex items-center justify-between">
              <div>
                <div className="font-semibold">{o.driver} · {o.time}</div>
                <div className="text-sm text-gray-600">{o.from} → {o.to} · {o.seats} place(s) restantes</div>
                {o.note && <div className="text-sm text-gray-500 mt-1">{o.note}</div>}
              </div>
              <div className="flex items-center gap-2">
                <button
                  className="px-3 py-2 rounded-lg border"
                  onClick={() => book(o)}
                  disabled={o.seats <= 0}
                >
                  {o.seats > 0 ? "Réserver" : "Complet"}
                </button>
              </div>
            </div>
          ))}
        </div>
      </Section>

      <Section title="Proposer un trajet">
        <div className="grid grid-cols-1 md:grid-cols-5 gap-3">
          <div>
            <label className="text-sm text-gray-600">Départ</label>
            <select value={from} onChange={(e) => setFrom(e.target.value)} className="w-full mt-1 border rounded-xl p-2">
              {RESIDENCES.map((r) => (
                <option key={r}>{r}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="text-sm text-gray-600">Arrivée</label>
            <input disabled value={to} className="w-full mt-1 border rounded-xl p-2 bg-gray-50" />
          </div>
          <div>
            <label className="text-sm text-gray-600">Heure</label>
            <input type="time" value={time} onChange={(e) => setTime(e.target.value)} className="w-full mt-1 border rounded-xl p-2" />
          </div>
          <div>
            <label className="text-sm text-gray-600">Places</label>
            <input type="number" min={1} max={4} value={seats} onChange={(e) => setSeats(e.target.value)} className="w-full mt-1 border rounded-xl p-2" />
          </div>
          <div>
            <label className="text-sm text-gray-600">Note</label>
            <input value={note} onChange={(e) => setNote(e.target.value)} placeholder="Point de RDV, itinéraire…" className="w-full mt-1 border rounded-xl p-2" />
          </div>
        </div>
        <div className="mt-4">
          <button onClick={publishOffer} className="bg-emerald-600 text-white rounded-xl px-4 py-2">Publier l'offre</button>
        </div>
      </Section>
    </>
  );
}

function RoutesSection({ state, setState }) {
  const [from, setFrom] = useState(state.user.residence);
  const [modePref, setModePref] = useState("eco"); // eco | rapide | vélo

  const distance = kmBetween(from, CAMPUS);
  const options = useMemo(() => {
    const bus = PT_LINES.find((l) => l.from === from);
    const walkingMins = Math.round((distance / 4.5) * 60); // 4.5 km/h
    const cyclingMins = Math.round((distance / 15) * 60); // 15 km/h
    const carMins = Math.round((distance / 28) * 60); // 28 km/h avg city

    const combos = [
      {
        id: "bike",
        title: "Vélo direct",
        steps: ["Prendre un vélo en libre-service", `${distance.toFixed(1)} km`],
        time: cyclingMins,
        co2: distance * CARBON_FACTORS.bike,
      },
      bus && {
        id: "bus",
        title: `Bus ${bus.id}`,
        steps: [
          `Rejoindre l'arrêt (${from})`,
          `Monter bus ${bus.id}`,
          `Descendre au ${CAMPUS}`,
        ],
        time: Math.max(12, Math.round(distance / 20 * 60)) + 6, // roughly
        co2: distance * CARBON_FACTORS.bus,
      },
      {
        id: "walk",
        title: "Marche",
        steps: ["Itinéraire piéton sécurisé", `${distance.toFixed(1)} km`],
        time: walkingMins,
        co2: distance * CARBON_FACTORS.walk,
      },
      {
        id: "carpool",
        title: "Covoiturage",
        steps: ["Rejoindre un conducteur", `${distance.toFixed(1)} km partagé`],
        time: carMins,
        co2: distance * CARBON_FACTORS.carShare,
      },
    ].filter(Boolean);

    if (modePref === "rapide") return combos.sort((a, b) => a.time - b.time);
    if (modePref === "vélo") return combos.filter((c) => c.id === "bike");
    return combos.sort((a, b) => a.co2 - b.co2); // eco by default
  }, [from, modePref, distance]);

  return (
    <>
      <Section title="Itinéraires multimodaux" right={
        <div className="flex gap-2">
          {['eco','rapide','vélo'].map((m)=> (
            <Pill key={m} active={modePref===m} onClick={()=>setModePref(m)}>{m.toUpperCase()}</Pill>
          ))}
        </div>
      }>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          <div>
            <label className="text-sm text-gray-600">Depuis</label>
            <select value={from} onChange={(e)=>setFrom(e.target.value)} className="w-full mt-1 border rounded-xl p-2">
              {RESIDENCES.map((r)=> <option key={r}>{r}</option>)}
            </select>
            <div className="text-xs text-gray-500 mt-2">Distance approx. {distance.toFixed(1)} km</div>
            <div className="mt-3 p-3 bg-gray-50 rounded-xl">
              <div className="font-semibold mb-1">Stations vélos proches</div>
              {BIKE_STATIONS.map((s)=> (
                <div key={s.id} className="text-sm flex justify-between">
                  <span>{s.name}</span>
                  <span className={s.available<5?"text-red-600":"text-gray-700"}>{s.available}</span>
                </div>
              ))}
            </div>
          </div>
          <div className="md:col-span-2 grid gap-3">
            {options.map((opt)=> (
              <div key={opt.id} className="border rounded-xl p-3 flex items-center justify-between">
                <div>
                  <div className="font-semibold">{opt.title}</div>
                  <div className="text-sm text-gray-600">{opt.steps.join(" · ")}</div>
                </div>
                <div className="text-right">
                  <div className="text-sm">{opt.time} min</div>
                  <div className="text-xs text-gray-500">{opt.co2.toFixed(2)} kg CO₂e</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </Section>
    </>
  );
}

function EmissionsSection({ state, setState }) {
  // Weekly goal = 10 kg CO2e saved
  const goal = 10;
  const pct = Math.min(100, Math.round((state.emissionsSavedKg / goal) * 100));

  const history = useMemo(() => {
    // Derive synthetic last 6 trips from bookings
    return state.bookings.slice(0, 6).map((b, i) => ({
      label: `Trajet ${i + 1}`,
      saved: 0.5 + (i % 3) * 0.3,
    }));
  }, [state.bookings]);

  return (
    <>
      <Section title="Objectif hebdomadaire">
        <div className="flex items-center gap-4">
          <div className="flex-1">
            <Progress value={state.emissionsSavedKg} max={goal} />
            <div className="text-sm text-gray-600 mt-2">{pct}% de l'objectif atteint · {state.emissionsSavedKg.toFixed(2)} / {goal} kg CO₂e évités</div>
          </div>
          <div className="flex gap-3">
            <Stat label="Trajets" value={state.bookings.length} />
            <Stat label="CO₂ évité" value={state.emissionsSavedKg.toFixed(1)} unit="kg" />
          </div>
        </div>
      </Section>

      <Section title="Derniers trajets économes">
        <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
          {history.length === 0 && (
            <div className="text-gray-500 text-sm">Aucun historique pour le moment.</div>
          )}
          {history.map((h, idx) => (
            <div key={idx} className="border rounded-xl p-3">
              <div className="font-semibold">{h.label}</div>
              <div className="text-sm text-gray-600">{h.saved.toFixed(2)} kg CO₂e</div>
            </div>
          ))}
        </div>
      </Section>

      <Section title="Gamification">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          <div className="p-4 rounded-xl bg-yellow-50 border border-yellow-100">
            <div className="font-semibold">Badge "Débrouillard·e"</div>
            <div className="text-sm text-gray-700">1er trajet en covoiturage réalisé ✅</div>
          </div>
          <div className="p-4 rounded-xl bg-green-50 border border-green-100">
            <div className="font-semibold">Badge "Économe"</div>
            <div className="text-sm text-gray-700">5 kg CO₂e évités 🎉</div>
          </div>
          <div className="p-4 rounded-xl bg-blue-50 border border-blue-100">
            <div className="font-semibold">Badge "Ambassadeur·rice"</div>
            <div className="text-sm text-gray-700">2 ami·e·s parrainé·e·s 👥</div>
          </div>
        </div>
      </Section>
    </>
  );
}

function PlanningSection({ state, setState }) {
  const [editing, setEditing] = useState(false);
  const [tmp, setTmp] = useState(state.schedule);

  function save() {
    setState({ ...state, schedule: tmp });
    setEditing(false);
  }

  function add() {
    setTmp([...tmp, { day: "Jeu", start: "08:30", end: "12:00" }]);
  }

  return (
    <>
      <Section title="Horaires de cours & transports">
        {!editing ? (
          <div>
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-gray-500">
                  <th className="py-2">Jour</th>
                  <th className="py-2">Début</th>
                  <th className="py-2">Fin</th>
                </tr>
              </thead>
              <tbody>
                {state.schedule.map((s, i) => (
                  <tr key={i} className="border-t">
                    <td className="py-2">{s.day}</td>
                    <td className="py-2">{s.start}</td>
                    <td className="py-2">{s.end}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <div className="mt-3 flex items-center justify-between">
              <div className="text-xs text-gray-500">Suggestion: partir 30 min avant l'heure de début. Les lignes PT correspondantes s'affichent dans Itinéraires.</div>
              <button className="px-3 py-2 rounded-lg border" onClick={() => setEditing(true)}>Modifier</button>
            </div>
          </div>
        ) : (
          <div>
            {tmp.map((s, i) => (
              <div key={i} className="grid grid-cols-3 gap-2 mb-2">
                <input value={s.day} onChange={(e)=>{
                  const nx=[...tmp]; nx[i]={...nx[i], day:e.target.value}; setTmp(nx);
                }} className="border rounded-xl p-2" />
                <input type="time" value={s.start} onChange={(e)=>{const nx=[...tmp]; nx[i]={...nx[i], start:e.target.value}; setTmp(nx);}} className="border rounded-xl p-2" />
                <input type="time" value={s.end} onChange={(e)=>{const nx=[...tmp]; nx[i]={...nx[i], end:e.target.value}; setTmp(nx);}} className="border rounded-xl p-2" />
              </div>
            ))}
            <div className="flex items-center gap-2 mt-2">
              <button className="px-3 py-2 rounded-lg border" onClick={add}>Ajouter</button>
              <button className="px-3 py-2 rounded-lg bg-emerald-600 text-white" onClick={save}>Enregistrer</button>
              <button className="px-3 py-2 rounded-lg" onClick={()=>setEditing(false)}>Annuler</button>
            </div>
          </div>
        )}
      </Section>
    </>
  );
}

function AlertsSection({ state, setState }) {
  const [text, setText] = useState("");
  const [type, setType] = useState("météo");

  function pushAlert() {
    const id = `${type}_${Date.now()}`;
    setState({ ...state, alerts: [{ id, type, text }, ...state.alerts] });
    setText("");
  }

  return (
    <>
      <Section title="Alertes en temps réel">
        <div className="grid grid-cols-1 md:grid-cols-5 gap-3">
          <div className="md:col-span-4">
            <div className="grid gap-2">
              {state.alerts.map((a) => (
                <div key={a.id} className="border rounded-xl p-3 flex items-center justify-between">
                  <div>
                    <div className="font-semibold capitalize">{a.type}</div>
                    <div className="text-sm text-gray-600">{a.text}</div>
                  </div>
                  <button className="px-3 py-2 rounded-lg border" onClick={() => setState({ ...state, alerts: state.alerts.filter(x => x.id !== a.id) })}>OK</button>
                </div>
              ))}
            </div>
          </div>
          <div>
            <div className="text-sm text-gray-600">Ajouter une alerte (simulation)</div>
            <select value={type} onChange={(e)=>setType(e.target.value)} className="w-full mt-1 border rounded-xl p-2">
              <option>météo</option>
              <option>trafic</option>
              <option>vélos</option>
            </select>
            <input value={text} onChange={(e)=>setText(e.target.value)} placeholder="Message…" className="w-full mt-2 border rounded-xl p-2" />
            <button onClick={pushAlert} className="w-full mt-2 bg-emerald-600 text-white rounded-xl p-2">Publier</button>
          </div>
        </div>
      </Section>

      <Section title="Intégrations prévues">
        <ul className="list-disc pl-5 text-sm text-gray-700 space-y-1">
          <li>Trafic: API ouvertes de cartographie (GTFS-RT, OpenTraffic, HERE, etc.).</li>
          <li>Météo: intégration d'un fournisseur (Open-Meteo) pour notifications ciblées.</li>
          <li>Vélos: webhooks opérateur pour disponibilité temps réel des stations.</li>
        </ul>
      </Section>
    </>
  );
}

/*
=========================================================
PWA PACK (ajouter ces deux fichiers à la racine du site)
=========================================================
1) manifest.webmanifest
{
  "name": "CampusMove",
  "short_name": "CampusMove",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ecfdf5",
  "theme_color": "#059669",
  "icons": [
    { "src": "/icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}

2) sw.js (service worker minimal pour cache offline basique)
const CACHE_NAME = 'campusmove-v1';
const ASSETS = [
  '/',
  '/index.html',
  '/manifest.webmanifest'
  // ajoutez vos bundles / images au besoin
];
self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE_NAME).then((c) => c.addAll(ASSETS)));
});
self.addEventListener('fetch', (e) => {
  e.respondWith(
    caches.match(e.request).then((r) => r || fetch(e.request))
  );
});

3) index.html – insérer dans <head> :
<link rel="manifest" href="/manifest.webmanifest" />
<meta name="theme-color" content="#059669" />

4) Déploiement ultra-simple :
- GitHub → "New repository" → pousser ces fichiers + build.
- Vercel ou Netlify → "New Project" → sélectionner le repo → Deploy.
- L’URL obtenue (ex: https://campusmove-demo.vercel.app) peut être scannée via QR.

5) Installation sur téléphone : ouvrir l’URL → menu navigateur → "Ajouter à l’écran d’accueil".
*/
