import React from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  getInventory,
  addRecord,
  updateRecord,
  deleteRecord
} from '../services/api';

export const InventoryTable: React.FC = () => {
  const queryClient = useQueryClient();
  const { data, isLoading } = useQuery(['inventory'], getInventory);

  const deleteMut = useMutation(deleteRecord, {
    onSuccess: () => queryClient.invalidateQueries(['inventory'])
  });

  if (isLoading) return <div>Loading…</div>;

  return (
    <table className="border-collapse border w-full">
      <thead>
        <tr className="bg-gray-200">
          <th>Serial</th><th>Artist</th><th>Media</th>
          <th>Year</th><th>Genre</th><th>Titles</th><th>Actions</th>
        </tr>
      </thead>
      <tbody>
        {data?.map(rec => (
          <tr key={rec.serial_number}>
            <td>{rec.serial_number}</td>
            <td>{rec.artist}</td>
            <td>{rec.media}</td>
            <td>{rec.year}</td>
            <td>{rec.genre}</td>
            <td>{rec.titles.join(', ')}</td>
            <td>
              {/* Admin actions – for brevity just delete */}
              <button
                className="text-red-600"
                onClick={() => deleteMut.mutate(rec.serial_number)}
              >Delete</button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

