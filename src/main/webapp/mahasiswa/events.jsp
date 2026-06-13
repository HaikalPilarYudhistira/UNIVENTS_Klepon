<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%
  String userName = session.getAttribute("userName") != null ? (String)session.getAttribute("userName") : null;
  String search   = request.getParameter("q") != null ? request.getParameter("q").trim() : "";
  String kat      = request.getParameter("kat") != null ? request.getParameter("kat").trim() : "";

  StringBuilder rows = new StringBuilder();
  try (Connection con = getConnection()) {
    String sql = "SELECT e.id,e.judul,e.deskripsi,e.lokasi,e.tanggal,e.waktu,e.kuota,e.kategori," +
                 "(SELECT COUNT(*) FROM pendaftaran p WHERE p.event_id=e.id) as peserta " +
                 "FROM events e WHERE e.status='aktif' ";
    if (!search.isEmpty()) sql += "AND (e.judul LIKE ? OR e.deskripsi LIKE ?) ";
    if (!kat.isEmpty())    sql += "AND e.kategori = ? ";
    sql += "ORDER BY e.tanggal ASC";

    PreparedStatement ps = con.prepareStatement(sql);
    int idx = 1;
    if (!search.isEmpty()) { ps.setString(idx++, "%" + search + "%"); ps.setString(idx++, "%" + search + "%"); }
    if (!kat.isEmpty())    ps.setString(idx++, kat);
    ResultSet rs = ps.executeQuery();

    boolean any = false;
    while (rs.next()) {
      any = true;
      String k = rs.getString("kategori");
      String icon = k.equals("akademik") ? "🎓" : k.equals("olahraga") ? "⚽" : k.equals("seni") ? "🎨" : "📅";
      int kuota = rs.getInt("kuota"), peserta = rs.getInt("peserta"), sisa = kuota - peserta;
      String badge = sisa > 20 ? "badge-green" : sisa > 0 ? "badge-yellow" : "badge-red";
      String sisat = sisa > 0 ? sisa + " tempat tersisa" : "Penuh";
      rows.append("<div class='card'>")
          .append("<div class='card-poster'>").append(icon).append("</div>")
          .append("<div class='card-body'>")
          .append("<div class='card-meta'><span class='badge'>").append(k).append("</span><span class='badge ").append(badge).append("'>").append(sisat).append("</span></div>")
          .append("<div class='card-title'>").append(rs.getString("judul")).append("</div>")
          .append("<div class='card-meta'><span>📍 ").append(rs.getString("lokasi")).append("</span><span>📅 ").append(rs.getDate("tanggal")).append(" ").append(rs.getString("waktu").substring(0,5)).append("</span></div>")
          .append("<div class='card-desc'>").append(rs.getString("deskripsi") != null ? rs.getString("deskripsi").substring(0, Math.min(100, rs.getString("deskripsi").length())) + "…" : "").append("</div>")
          .append("<a href='detail.jsp?id=").append(rs.getInt("id")).append("' class='btn btn-primary btn-sm'>Lihat &amp; Daftar →</a>")
          .append("</div></div>");
    }
    if (!any) rows.append("<p style='grid-column:1/-1;text-align:center;padding:3rem 0;color:var(--text-muted)'>Tidak ada event ditemukan.</p>");
  } catch (Exception ex) {
    rows.append("<p style='color:red;grid-column:1/-1;padding:2rem'>Error: ").append(ex.getMessage()).append("</p>");
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Daftar Event — UNIVENTS</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar">
  <a href="../landing/index.jsp" class="navbar-brand">🎓 UNI<span>VENTS</span></a>
  <div class="navbar-links">
    <a href="events.jsp" class="active">Event</a>
    <% if (userName != null) { %>
      <a href="notifikasi.jsp">🔔 Notifikasi</a>
      <a href="profile.jsp"><%=userName%></a>
      <a href="logout.jsp" class="btn btn-outline btn-sm">Keluar</a>
    <% } else { %>
      <a href="login.jsp" class="btn btn-outline btn-sm">Masuk</a>
      <a href="register.jsp" class="btn btn-primary btn-sm">Daftar</a>
    <% } %>
  </div>
</nav>

<div class="container section">
  <h1 style="font-size:1.5rem;font-weight:800;margin-bottom:1.5rem">🗓 Event Kampus</h1>

  <!-- Search & Filter -->
  <form method="GET" style="display:flex;gap:.75rem;flex-wrap:wrap;margin-bottom:2rem;align-items:flex-end;">
    <div style="flex:1;min-width:200px;">
      <input type="text" name="q" value="<%=search%>" placeholder="Cari event..." style="width:100%;padding:.65rem .9rem;border:1.5px solid var(--border);border-radius:8px;font-size:.9rem;">
    </div>
    <select name="kat" style="padding:.65rem .9rem;border:1.5px solid var(--border);border-radius:8px;font-size:.9rem;background:#fff;">
      <option value="">Semua Kategori</option>
      <option value="akademik"     <%=kat.equals("akademik")      ? "selected":""%>>Akademik</option>
      <option value="non-akademik" <%=kat.equals("non-akademik")  ? "selected":""%>>Non-Akademik</option>
      <option value="olahraga"     <%=kat.equals("olahraga")      ? "selected":""%>>Olahraga</option>
      <option value="seni"         <%=kat.equals("seni")          ? "selected":""%>>Seni</option>
      <option value="lainnya"      <%=kat.equals("lainnya")       ? "selected":""%>>Lainnya</option>
    </select>
    <button type="submit" class="btn btn-primary">Cari</button>
    <% if (!search.isEmpty() || !kat.isEmpty()) { %>
      <a href="events.jsp" class="btn btn-outline">Reset</a>
    <% } %>
  </form>

  <div class="card-grid">
    <%=rows%>
  </div>
</div>

<footer style="background:var(--text);color:#fff;padding:1.5rem;text-align:center;font-size:.85rem;margin-top:3rem;">
  © 2025 UNIVENTS — Kelompok Klepon
</footer>
</body>
</html>
