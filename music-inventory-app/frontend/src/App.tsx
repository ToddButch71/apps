import React, { useState } from 'react';
import { InventoryTable } from './components/InventoryTable';

const App = () => {
  const [search, setSearch] = useState('');

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Music Inventory</h1>
      <input
      type="text"
      placeholder="Search any field…"
      className="border p-2 mb-4 w-full"
      value={search}
      onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSearch(e.target.value)}
      />
      <InventoryTable search={search} />
    </div>
  );
};

export default App;

