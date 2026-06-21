import { Vehicle } from './types';

export const VEHICLES: Vehicle[] = [
  { id: 'camry-2023', displayName: '2023 Toyota Camry' },
  { id: 'civic-2022', displayName: '2022 Honda Civic' },
];

// Travel Mode will eventually choose this for real; for standalone testing
// of this layer we hardcode a single active vehicle.
export const HARDCODED_ACTIVE_VEHICLE_ID = 'camry-2023';
