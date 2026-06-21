import { CachedContentItem } from '../data/types';

const HELP_TYPE_LABEL: Record<string, string> = {
  tow: 'Tow',
  service_station: 'Service Station',
  town: 'Town',
};

export function citationLabel(item: CachedContentItem): string {
  if (item.contentType === 'manual') {
    return `${item.sectionTitle}, p. ${item.pageRef}`;
  }
  return `${item.name}, mile ${item.mileMarker}`;
}

export function citationDetail(item: CachedContentItem): string {
  if (item.contentType === 'manual') {
    return `Section "${item.sectionTitle}", page ${item.pageRef}`;
  }
  const typeLabel = HELP_TYPE_LABEL[item.helpType] ?? item.helpType;
  const phone = item.phoneIfKnown ? `, phone ${item.phoneIfKnown}` : '';
  return `${item.name} (${typeLabel}), mile marker ${item.mileMarker}, ${item.distanceFromRoute} mi from route${phone}`;
}
