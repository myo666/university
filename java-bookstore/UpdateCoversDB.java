import com.bookstore.util.DBUtil;
import java.sql.*;

public class UpdateCoversDB {
    public static void main(String[] args) throws Exception {
        String[] covers = {
            "images/cover_1.png",  "images/cover_2.png",  "images/cover_3.png",
            "images/cover_4.png",  "images/cover_5.png",  "images/cover_6.png",
            "images/cover_7.png",  "images/cover_8.png",  "images/cover_9.png",
            "images/cover_10.png", "images/cover_11.png", "images/cover_12.png"
        };
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE books SET cover = ? WHERE id = ?")) {
            for (int i = 0; i < covers.length; i++) {
                ps.setString(1, covers[i]);
                ps.setInt(2, i + 1);
                int rows = ps.executeUpdate();
                System.out.println("Book " + (i+1) + ": updated " + rows + " row(s)");
            }
            System.out.println("Done.");
        } catch (SQLException e) { e.printStackTrace(); }
    }
}
