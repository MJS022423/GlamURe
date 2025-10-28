// Dashboard.jsx
import React from 'react';
import Sidebar from './sidebar';
import Header from './header';

function Dashboard() {

  return (
    <div className="dashboard-container">
        <Header />
        <div className="main-layout">
            <div className='leftside'>
                <Sidebar />
            </div>
            <main>
                {/* Place page content here */}
            </main>
            <aside></aside>
        </div>
    </div>
  );
}

export default Dashboard;

