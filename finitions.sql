-- 1. Statistiques anonymes des véhicules analysés (aucun lien avec le compte)
create table if not exists public.observations (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  type text, marque text, autre text, annee int, km int, prix int,
  vendeur text, pays text, opts text[], cote int
);
alter table public.observations enable row level security;
grant insert on public.observations to anon, authenticated;
drop policy if exists "ajouter" on public.observations;
create policy "ajouter" on public.observations for insert to anon, authenticated with check (prix between 1000 and 1000000);

-- 2. Suppression de son propre compte depuis « Mon espace »
create or replace function public.supprimer_mon_compte()
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'non connecté'; end if;
  delete from public.rapports where user_id = auth.uid();
  delete from public.recherches where user_id = auth.uid();
  delete from public.offres where user_id = auth.uid();
  delete from auth.users where id = auth.uid();
end; $$;
revoke all on function public.supprimer_mon_compte() from public, anon;
grant execute on function public.supprimer_mon_compte() to authenticated;
