SELECT 
    e.event_id AS "ID Ивента",
    e.title AS "Название Мероприятия",
    g.genre_name AS "Жанр",
    e.event_date AS "Дата",
    e.status AS "Статус",
    (v.venue_name || ' (Вместимость: ' || v.capacity || ')') AS "Площадка (Вместимость)",
    o.company_name AS "Организатор",
    a.artist_name AS "Выступающий Артист/Спикер",
    att.full_name AS "Покупатель Билета",
    t.ticket_type AS "Тип билета",
    t.total_price AS "Сумма (KZT)",
    p.payment_method AS "Способ Оплаты",
    p.payment_status AS "Статус Платежа"
FROM event_schema.events e
LEFT JOIN event_schema.genres g ON e.genre_id = g.genre_id
LEFT JOIN event_schema.organizers o ON e.organizer_id = o.organizer_id
LEFT JOIN event_schema.venues v ON e.venue_id = v.venue_id
LEFT JOIN event_schema.event_artists ea ON e.event_id = ea.event_id
LEFT JOIN event_schema.artists a ON ea.artist_id = a.artist_id
LEFT JOIN event_schema.tickets t ON e.event_id = t.event_id
LEFT JOIN event_schema.attendees att ON t.attendee_id = att.attendee_id
LEFT JOIN event_schema.payments p ON t.ticket_id = p.ticket_id
ORDER BY e.event_id;