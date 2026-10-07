-- =====================================================
-- Géolocalisation des ambulances FFSS 41
-- Étape 1 : table des véhicules
-- =====================================================

create table if not exists public.vehicules (
  id               uuid primary key default gen_random_uuid(),
  nom              text not null,
  -- Clé secrète saisie dans Traccar Client ("Identifiant de l'appareil").
  -- Générée automatiquement, longue et impossible à deviner.
  cle_traccar      text not null unique default replace(gen_random_uuid()::text, '-', ''),
  statut           text not null default 'indisponible'
                   check (statut in ('disponible', 'en_intervention', 'en_transport', 'indisponible')),
  -- Dernière position connue uniquement (pas d'historique : RGPD)
  latitude         double precision,
  longitude        double precision,
  vitesse_kmh      double precision,
  precision_m      double precision,
  derniere_position timestamptz,
  created_at       timestamptz not null default now()
);

-- Sécurité : seules les personnes connectées peuvent voir et modifier
alter table public.vehicules enable row level security;

drop policy if exists "Lecture vehicules connectes" on public.vehicules;
create policy "Lecture vehicules connectes"
  on public.vehicules for select
  to authenticated
  using (true);

drop policy if exists "Modification statut connectes" on public.vehicules;
create policy "Modification statut connectes"
  on public.vehicules for update
  to authenticated
  using (true)
  with check (true);

-- Temps réel : la carte se met à jour toute seule
alter publication supabase_realtime add table public.vehicules;

-- Tes ambulances (modifie les noms si besoin, ajoute ou retire des lignes)
insert into public.vehicules (nom) values
  ('VPSP 12'),
  ('VPSP 13'),
  ('VPSP 14'),
  ('VPSP 15'),
  ('VLC 41'),
  ('VLTT 41'),
  ('VPL 41');
