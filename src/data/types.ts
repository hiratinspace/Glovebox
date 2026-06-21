export type ManualChunk = {
  id: string;
  vehicleId: string;
  contentType: 'manual';
  sectionTitle: string;
  pageRef: number;
  text: string;
};

export type HelpWaypoint = {
  id: string;
  vehicleId: null;
  contentType: 'nearby_help';
  name: string;
  helpType: 'tow' | 'service_station' | 'town';
  mileMarker: number;
  distanceFromRoute: number;
  phoneIfKnown: string | null;
};

export type CachedContentItem = ManualChunk | HelpWaypoint;

export type Vehicle = {
  id: string;
  displayName: string;
};
