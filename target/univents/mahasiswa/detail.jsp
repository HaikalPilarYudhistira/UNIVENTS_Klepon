<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%
  Integer userId = (Integer) session.getAttribute("userId");
  String userName = userId != null ? (String) session.getAttribute("userName") : null;

  int id = 0;
  try { id = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
  if (id == 0) { response.sendRedirect("events.jsp"); return; }

  String msg = "", msgType = "";

  // Handle pendaftaran POST
  if ("POST".equalsIgnoreCase(request.getMethod()) && userId != null) {
    String action = request.getParameter("action");
    try (Connection con = getConnection()) {
      if ("daftar".equals(action)) {
        // Cek kuota
        PreparedStatement ck = con.prepareStatement(
          "SELECT kuota, (SELECT COUNT(*) FROM pendaftaran WHERE event_id=?) as peserta FROM events WHERE id=?");
        ck.setInt(1, id); ck.setInt(2, id);
        ResultSet rck = ck.executeQuery();
        if (rck.next() && rck.getInt("peserta") < rck.getInt("kuota")) {
          PreparedStatement ins = con.prepareStatement(
            "INSERT IGNORE INTO pendaftaran (event_id,user_id) VALUES (?,?)");
          ins.setInt(1, id); ins.setInt(2, userId);
          int aff = ins.executeUpdate();
          if (aff > 0) {
            // Kirim notifikasi
            PreparedStatement notif = con.prepareStatement(
              "INSERT INTO notifikasi (user_id,pesan) SELECT ?,CONCAT('Pendaftaran event \"',judul,'\" berhasil!') FROM events WHERE id=?");
            notif.setInt(1, userId); notif.setInt(2, id); notif.executeUpdate();
            msg = "Pendaftaran berhasil! Kamu sudah terdaftar di event ini."; msgType = "success";
          } else {
            msg = "Kamu sudah terdaftar di event ini."; msgType = "info";
          }
        } else {
          msg = "Maaf, kuota event ini sudah penuh."; msgType = "error";
        }
      } else if ("batal".equals(action)) {
        PreparedStatement del = con.prepareStatement(
          "DELETE FROM pendaftaran WHERE event_id=? AND user_id=?");
        del.setInt(1, id); del.setInt(2, userId); del.executeUpdate();
        msg = "Pendaftaran dibatalkan."; msgType = "info";
      }
    } catch (Exception ex) { msg = "Error: " + ex.getMessage(); msgType = "error"; }
  }

  // Load event detail
  String judul="", deskripsi="", lokasi="", tanggal="", waktu="", kategori="";
  int kuota=0, peserta=0;
  boolean sudahDaftar = false;
  try (Connection con = getConnection()) {
    PreparedStatement ps = con.prepareStatement(
      "SELECT e.*,(SELECT COUNT(*) FROM pendaftaran p WHERE p.event_id=e.id) as peserta FROM events e WHERE e.id=?");
    ps.setInt(1, id);
    ResultSet rs = ps.executeQuery();
    if (!rs.next()) { response.sendRedirect("events.jsp"); return; }
    judul     = rs.getString("judul");
    deskripsi = rs.getString("deskripsi");
    lokasi    = rs.getString("lokasi");
    tanggal   = rs.getDate("tanggal").toString();
    waktu     = rs.getString("waktu").substring(0,5);
    kategori  = rs.getString("kategori");
    kuota     = rs.getInt("kuota");
    peserta   = rs.getInt("peserta");

    if (userId != null) {
      PreparedStatement ps2 = con.prepareStatement(
        "SELECT 1 FROM pendaftaran WHERE event_id=? AND user_id=?");
      ps2.setInt(1, id); ps2.setInt(2, userId);
      sudahDaftar = ps2.executeQuery().next();
    }
  }
  int sisa = kuota - peserta;
  String icon = kategori.equals("akademik") ? "🎓" : kategori.equals("olahraga") ? "⚽" : kategori.equals("seni") ? "🎨" : "📅";
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%=judul%> — UNIVENTS</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar">
  <a href="../landing/index.jsp" class="navbar-brand">🎓 UNI<span>VENTS</span></a>
  <div class="navbar-links">
    <a href="events.jsp">← Semua Event</a>
    <% if (userName != null) { %>
      <a href="notifikasi.jsp">🔔 Notifikasi</a>
      <a href="logout.jsp" class="btn btn-outline btn-sm">Keluar</a>
    <% } else { %>
      <a href="login.jsp" class="btn btn-primary btn-sm">Masuk untuk Daftar</a>
    <% } %>
  </div>
</nav>

<div class="container section" style="max-width:760px">
  <!-- Poster placeholder -->
  <div style="background:linear-gradient(135deg,var(--primary),#2563EB);border-radius:var(--radius);height:220px;display:flex;align-items:center;justify-content:center;font-size:5rem;margin-bottom:2rem;">
    <%=icon%>
  </div>

  <!-- Alert -->
  <% if (!msg.isEmpty()) { %>
    <div class="alert alert-<%=msgType.equals("error")?"error":msgType.equals("success")?"success":"info"%>" style="margin-bottom:1.5rem">
      <%=msg%>
    </div>
  <% } %>

  <!-- Badge + Judul -->
  <div style="display:flex;gap:.75rem;flex-wrap:wrap;margin-bottom:.75rem;align-items:center;">
    <span class="badge"><%=kategori%></span>
    <span class="badge <%=sisa > 20 ? "badge-green" : sisa > 0 ? "badge-yellow" : "badge-red"%>">
      <%=sisa > 0 ? sisa + " tempat tersisa" : "Penuh"%>
    </span>
  </div>

  <h1 style="font-size:1.8rem;font-weight:800;margin-bottom:1rem"><%=judul%></h1>

  <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:.75rem;margin-bottom:1.5rem;">
    <div style="background:var(--white);border:1px solid var(--border);border-radius:10px;padding:.75rem 1rem;font-size:.875rem;">
      <div style="color:var(--text-muted);font-size:.75rem;font-weight:600;margin-bottom:.2rem">TANGGAL</div>
      <strong>📅 <%=tanggal%></strong>
    </div>
    <div style="background:var(--white);border:1px solid var(--border);border-radius:10px;padding:.75rem 1rem;font-size:.875rem;">
      <div style="color:var(--text-muted);font-size:.75rem;font-weight:600;margin-bottom:.2rem">WAKTU</div>
      <strong>⏰ <%=waktu%> WIB</strong>
    </div>
    <div style="background:var(--white);border:1px solid var(--border);border-radius:10px;padding:.75rem 1rem;font-size:.875rem;">
      <div style="color:var(--text-muted);font-size:.75rem;font-weight:600;margin-bottom:.2rem">LOKASI</div>
      <strong>📍 <%=lokasi%></strong>
    </div>
    <div style="background:var(--white);border:1px solid var(--border);border-radius:10px;padding:.75rem 1rem;font-size:.875rem;">
      <div style="color:var(--text-muted);font-size:.75rem;font-weight:600;margin-bottom:.2rem">PESERTA</div>
      <strong>👥 <%=peserta%> / <%=kuota%></strong>
    </div>
  </div>

  <div style="background:var(--white);border:1px solid var(--border);border-radius:var(--radius);padding:1.5rem;margin-bottom:2rem;">
    <h3 style="font-size:1rem;font-weight:700;margin-bottom:.75rem">Deskripsi Event</h3>
    <p style="font-size:.9rem;line-height:1.7;color:var(--text)"><%=deskripsi != null ? deskripsi : "Tidak ada deskripsi."  %></p>
  </div>

  <!-- Tombol Daftar / Batal -->
  <% if (userName == null) { %>
    <div class="alert alert-info">
      <a href="login.jsp" style="font-weight:700">Masuk</a> atau <a href="register.jsp" style="font-weight:700">buat akun</a> untuk mendaftar event ini.
    </div>
  <% } else if (sudahDaftar) { %>
    <div style="display:flex;gap:1rem;flex-wrap:wrap;align-items:center;">
      <div class="alert alert-success" style="margin:0;flex:1">✅ Kamu sudah terdaftar di event ini.</div>
      <form method="POST">
        <input type="hidden" name="action" value="batal">
        <button class="btn btn-danger">Batalkan Pendaftaran</button>
      </form>
    </div>
  <% } else if (sisa > 0) { %>
    <form method="POST">
      <input type="hidden" name="action" value="daftar">
      <button class="btn btn-primary" style="font-size:1rem;padding:.75rem 2rem">🎟 Daftar Sekarang</button>
    </form>
  <% } else { %>
    <div class="alert alert-error">Maaf, kuota event ini sudah habis.</div>
  <% } %>
</div>

<footer style="background:var(--text);color:#fff;padding:1.5rem;text-align:center;font-size:.85rem;margin-top:3rem;">
  © 2025 UNIVENTS — Kelompok Klepon
</footer>
</body>
</html>
