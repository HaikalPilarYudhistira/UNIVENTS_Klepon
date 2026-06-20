<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%@ include file="/WEB-INF/auth_admin.jsp" %>
<%
  int id = 0;
  try { id = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
  if (id > 0) {
    try (Connection con = getConnection()) {
      PreparedStatement ps = con.prepareStatement("DELETE FROM events WHERE id=?");
      ps.setInt(1, id); ps.executeUpdate();
    } catch (Exception ignored) {}
  }
  response.sendRedirect("event_list.jsp");
%>
