import React from 'react';

export interface Column<T> {
    header: React.ReactNode;
    accessorKey?: keyof T;
    cell?: (row: T) => React.ReactNode;
    width?: string;
}

interface DataTableProps<T> {
    columns: Column<T>[];
    data: T[];
    emptyMessage?: React.ReactNode;
    minWidth?: string;
}

function DataTable<T>({ columns, data, emptyMessage = "No data found", minWidth = '800px' }: DataTableProps<T>) {
    return (
        <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', minWidth: minWidth }}>
                <thead>
                    <tr style={{ backgroundColor: '#f9fafb', borderBottom: '1px solid #e0e0e0' }}>
                        {columns.map((col, index) => (
                            <th key={index} style={{
                                padding: '0.75rem',
                                textAlign: 'left',
                                fontSize: '0.8rem',
                                fontWeight: 600,
                                color: '#444',
                                whiteSpace: 'nowrap',
                                width: col.width
                            }}>
                                {col.header}
                            </th>
                        ))}
                    </tr>
                </thead>
                <tbody>
                    {data.length > 0 ? (
                        data.map((row, rowIndex) => (
                            <tr key={rowIndex} style={{ borderBottom: '1px solid #f0f0f0' }}>
                                {columns.map((col, colIndex) => (
                                    <td key={colIndex} style={{ padding: '0.75rem', fontSize: '0.9rem', color: '#333' }}>
                                        {col.cell ? col.cell(row) : (col.accessorKey ? String(row[col.accessorKey]) : null)}
                                    </td>
                                ))}
                            </tr>
                        ))
                    ) : (
                        <tr>
                            <td colSpan={columns.length} style={{ padding: '2rem', textAlign: 'center', color: '#666' }}>
                                {typeof emptyMessage === 'string' ? (
                                    <div style={{ marginBottom: '0.5rem' }}>{emptyMessage}</div>
                                ) : (
                                    emptyMessage
                                )}
                            </td>
                        </tr>
                    )}
                </tbody>
            </table>
        </div>
    );
}

export default DataTable;
